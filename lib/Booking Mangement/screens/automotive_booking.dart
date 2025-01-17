import 'package:autocare_automotiveshops/Authentication/Widgets/snackBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import '../../Messages Management/services/chat_service.dart';
import '../../ProfileManagement/services/commission_services.dart';
import '../models/booking_model.dart';
import '../services/booking_services.dart';
import '../widgets/bookingButton.dart';

class AutomotiveBookingScreen extends StatefulWidget {
  const AutomotiveBookingScreen({super.key, this.child});

  final Widget? child;

  @override
  State<AutomotiveBookingScreen> createState() => _AutomotiveBookingState();
}

class _AutomotiveBookingState extends State<AutomotiveBookingScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  final Logger logger = Logger();
  final BookingService _bookingService = BookingService();
  final ChatService _chatService = ChatService();
  Map<DateTime, List<BookingModel>> _events = {};
  DateTime _selectedDate = DateTime.now();
  List<BookingModel> _selectedBookings = [];
  bool isLoading = false;
  String? currentBookingId;
  List<BookingModel> bookings = [];

  @override
  void initState() {
    super.initState();
    _fetchBookings();
    _loadBookings();
  }

  Future<void> _fetchBookings() async {
    String serviceProviderUid = user!.uid;
    List<BookingModel> bookings =
        await _bookingService.fetchBookingRequests(serviceProviderUid);

    Map<DateTime, List<BookingModel>> groupedBookings = {};

    for (var booking in bookings) {
      try {
        DateTime bookingDate =
            DateFormat('dd/MM/yyyy').parse(booking.bookingDate);
        DateTime normalizedDate = _normalizeDate(bookingDate);

        if (groupedBookings[normalizedDate] == null) {
          groupedBookings[normalizedDate] = [booking];
        } else {
          groupedBookings[normalizedDate]!.add(booking);
        }
      } catch (e) {
        logger.e(
            'Error parsing booking date for ${booking.bookingId}: ${booking.bookingDate}, $e');
      }
    }

    setState(() {
      _events = groupedBookings;
      logger.i('EVENTS: $_events');
      _selectedBookings = _events[_normalizeDate(_selectedDate)] ?? [];
      logger.i('SELECTED BOOKINGS: $_selectedBookings');
    });
  }

  Future<void> _loadBookings() async {
    try {
      List<BookingModel> carOwnerBookings =
      await BookingService().fetchBookings(user!.uid);
      logger.i('BOOKINGS', carOwnerBookings);
      setState(() {
        bookings = carOwnerBookings;
        isLoading = false;
      });
    } catch (e) {
      logger.i('Error loading bookings: $e');
      setState(() {
        isLoading = false;
      });
    }
  }


  Future<void> markBookingAsDone(BookingModel booking) async {
    try {
      final bookingDate = booking.bookingDate.trim();
      final bookingTime =
          booking.bookingTime.replaceAll(RegExp(r'\s+'), ' ').trim();

      // Combine and parse bookingDate and bookingTime into a DateTime object
      final dateTimeFormat = DateFormat("dd/MM/yyyy hh:mm a");
      final bookingDateTime = dateTimeFormat.parse('$bookingDate $bookingTime');

      // Get the current date and time
      final currentDateTime = DateTime.now();

      // Check if the current date and time align with the booking date and time
      if (bookingDateTime.isAfter(currentDateTime)) {
        Utils.showSnackBar(
            'Cannot mark booking as done before the scheduled time.');
        return;
      }

      await _bookingService.updateBookingStatus(booking.bookingId!, 'done');

      logger.i('Booking marked as done: ${booking.bookingId}');

      setState(() {
        booking.status = 'done';
      });

      final conversationId = await ChatService().initializeConversation(
        booking.serviceProviderUid,
        booking.carOwnerUid,
      );

      await _chatService.sendBookingDoneMessage(conversationId, booking);
      logger.i(conversationId);

      await CommissionService.saveCommissionDetails(booking);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking marked as done'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      logger.e('Failed to mark booking as done: ${booking.bookingId}, $error');

      Utils.showSnackBar('Failed to update booking status. Try again.');
    }
  }

  Future<void> cancelBooking(
      String bookingId, String shopId, String date, String time) async {
    try {
      BookingService bookingsService = BookingService();

      await bookingsService.deleteBooking(bookingId);

      DocumentReference shopRef = FirebaseFirestore.instance
          .collection('automotiveShops_profile')
          .doc(shopId);

      DocumentSnapshot snapshot = await shopRef.get();

      if (snapshot.exists) {
        Map<String, dynamic> shopData = snapshot.data() as Map<String, dynamic>;
        Map<String, dynamic> remainingSlots = shopData['remainingSlots'] ?? {};

        if (remainingSlots.containsKey(date) &&
            remainingSlots[date] is Map<String, dynamic>) {
          Map<String, dynamic> timeSlots = remainingSlots[date];

          if (timeSlots.containsKey(time)) {
            int currentSlots = timeSlots[time] as int;
            timeSlots[time] = currentSlots + 1; // Increment remaining slots

            await shopRef.update({
              'remainingSlots': remainingSlots,
            });
          }
        }

        setState(() {
          bookings.removeWhere((b) => b.bookingId == bookingId);
        });

        // Show a confirmation message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking Cancelled Successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Handle errors, if any
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to cancel booking'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }



  Future<void> _handleDecline(BookingModel booking) async {
    setState(() {
      isLoading = true;
      currentBookingId = booking.bookingId;
    });

    try {
      await _bookingService.updateBookingStatus(booking.bookingId!, 'declined');
      logger.i('Booking declined: ${booking.bookingId}');

      setState(() {
        booking.status = 'declined';
      });

      final conversationId = await ChatService().initializeConversation(
        booking.serviceProviderUid,
        booking.carOwnerUid,
      );

      await _chatService.sendBookingDeclineMessage(conversationId, booking);
      logger.i(conversationId);

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking declined'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      logger.e('Error declining booking: ${booking.bookingId}, $e');

      Utils.showSnackBar('Error declining booking: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _handleAccept(BookingModel booking) async {
    setState(() {
      isLoading = true;
      currentBookingId = booking.bookingId;
    });

    try {
      // Update booking status
      await _bookingService.updateBookingStatus(
          booking.bookingId!, 'confirmed');
      logger.i('Booking accepted: ${booking.bookingId}');

      setState(() {
        booking.status = 'confirmed';
      });

      // Check or initialize conversation
      final conversationId = await ChatService().initializeConversation(
        booking.serviceProviderUid,
        booking.carOwnerUid,
      );

      // Send the confirmation message
      await _chatService.sendBookingConfirmationMessage(
          conversationId, booking);
      logger.i(conversationId);

      Navigator.pop(context);

      // Show confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking accepted'),
          backgroundColor: Colors.blue,
        ),
      );
    } catch (e) {
      logger.e('Error accepting booking: ${booking.bookingId}, $e');

      Utils.showSnackBar('Error declining booking: $e');
    } finally {
      setState(() {
        isLoading = false; // Reset loading state
      });
    }
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  void _showBookingDetailsModal(List<BookingModel> bookings) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Column(
              children: bookings.map((booking) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  'Service: ${booking.selectedService.join(', ')}',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '${booking.bookingDate}, ${booking.bookingTime}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.php,
                                color: Colors.blue,
                                size: 20,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                booking.totalPrice.toStringAsFixed(2),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.person,
                                color: Colors.blue,
                                size: 20,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                booking.fullName,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.phone,
                                color: Colors.blue,
                                size: 20,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                booking.phoneNumber!,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.directions_car,
                                color: Colors.blue,
                                size: 20,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '${booking.carBrand} ${booking.carModel} Year: ${booking.carYear}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.local_gas_station,
                                color: Colors.blue,
                                size: 20,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                booking.fuelType,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.settings,
                                color: Colors.blue,
                                size: 20,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                booking.transmission,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (isLoading == true &&
                              currentBookingId == booking.bookingId)
                            const Center(
                                child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.orange)))
                          else if (booking.status != 'pending')
                            RichText(
                              text: TextSpan(
                                children: [
                                  const TextSpan(
                                    text: 'Status: ',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '${booking.status?.toUpperCase()}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else if (isLoading == false)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                BookingButton(
                                  text: 'Decline',
                                  color: Colors.red,
                                  padding: 5.0,
                                  onTap: () async {
                                    await _handleDecline(booking);
                                  },
                                ),
                                BookingButton(
                                  text: 'Accept',
                                  color: Colors.orange,
                                  padding: 5.0,
                                  onTap: () async {
                                    await _handleAccept(booking);
                                  },
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        });
  }

  Widget _buildEventMarker(List<BookingModel> bookings) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.orange.shade900,
      ),
    );
  }

  Widget _buildBookingSection({
    required String status,
    required List<BookingModel> bookings,
    required String emptyMessage,
    required Color color,
    bool isMarkAsDoneEnabled = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Header
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.all(12.0),
            child: Text(
              status,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Booking List or Empty Message
          bookings.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      emptyMessage,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    BookingModel booking = bookings[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Booking Title
                            Text(
                              booking.selectedService.join(', ').toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            const Divider(),
                            // Booking Details
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildDetailRow(
                                        icon: Icons.calendar_today,
                                        text: '${booking.bookingDate}, ${booking.bookingTime}',
                                      ),
                                      const SizedBox(height: 8),
                                      _buildDetailRow(
                                        icon: Icons.php,
                                        text: booking.totalPrice.toStringAsFixed(2),
                                      ),
                                      const SizedBox(height: 8),
                                      _buildDetailRow(
                                        icon: Icons.person,
                                        text: booking.fullName,
                                      ),
                                      const SizedBox(height: 8),
                                      // Status
                                      Row(
                                        children: [
                                          const Icon(Icons.info, color: Colors.orange, size: 20),
                                          const SizedBox(width: 5),
                                          Text(
                                            booking.status?.toUpperCase() ?? '',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.orange,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Action Buttons
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (isMarkAsDoneEnabled || booking.status == 'declinec')
                                      ElevatedButton(
                                        onPressed: () async {
                                          await markBookingAsDone(booking);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0, horizontal: 12.0),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8.0),
                                          ),
                                        ),
                                        child: const Text(
                                          'Mark as Done',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    const SizedBox(height: 8), // Space between buttons
                                    if (isMarkAsDoneEnabled)
                                    ElevatedButton(
                                      onPressed: () async {
                                        bool? confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text(
                                                  'Confirm Removal'),
                                              content: const Text(
                                                'Are you sure you want to remove this booking?',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(false); // Cancel
                                                  },
                                                  child: const Text(
                                                    'No',
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(true);
                                                  },
                                                  child: const Text(
                                                    'Yes',
                                                    style: TextStyle(
                                                        color: Colors.orange),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        );

                                        if (confirm == true) {
                                          await cancelBooking(
                                            booking.bookingId!,
                                            booking.serviceProviderUid,
                                            booking.bookingDate,
                                            booking.bookingTime,
                                          );
                                          setState(() {
                                            bookings.removeWhere((b) =>
                                            b.bookingId == booking.bookingId);
                                          });

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Booking Removed Successfully!'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 5.0, horizontal: 8.0),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(8.0),
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                      child: const Text(
                                        'Remove Booking',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

// Helper Widget for Detail Rows
  Widget _buildDetailRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Bookings',
              style: TextStyle(fontWeight: FontWeight.w900)),
          backgroundColor: Colors.grey.shade100,
          bottom: TabBar(
            indicatorColor: Colors.orange.shade900,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: const [
              Tab(
                child: Text(
                  'Calendar View',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  'Bookings Today',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Column(
              children: [
                const SizedBox(height: 10),
                TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _selectedDate,
                  calendarFormat: CalendarFormat.month,
                  selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDate = _normalizeDate(selectedDay);
                      _selectedBookings =
                          _events[_normalizeDate(selectedDay)] ?? [];
                      if (_selectedBookings.isNotEmpty) {
                        _showBookingDetailsModal(_selectedBookings);
                      }
                    });
                  },
                  eventLoader: (day) {
                    return _events[_normalizeDate(day)] ?? [];
                  },
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, date, events) {
                      if (events.isNotEmpty) {
                        return Positioned(
                          bottom: 1,
                          child:
                              _buildEventMarker(events as List<BookingModel>),
                        );
                      }
                      return null;
                    },
                  ),
                  headerStyle: HeaderStyle(
                    titleCentered: true,
                    titleTextStyle: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    formatButtonVisible: false,
                    leftChevronIcon: const Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                      size: 30,
                    ),
                    rightChevronIcon: const Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                      size: 30,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade900,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                  ),
                  calendarStyle: CalendarStyle(
                    selectedDecoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.5),
                          blurRadius: 3,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    todayDecoration: BoxDecoration(
                      color: Colors.orange.shade900,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.5),
                          blurRadius: 3,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    defaultDecoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                    ),
                    weekendDecoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.6),
                          blurRadius: 6,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    outsideDecoration: const BoxDecoration(
                      color: Colors.transparent,
                    ),
                    cellMargin: const EdgeInsets.all(4),
                    todayTextStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    selectedTextStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    weekendTextStyle: TextStyle(
                      color: Colors.red.shade300,
                      fontSize: 14,
                    ),
                    defaultTextStyle: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.25,
                  child: ClipRRect(
                    child: Image.asset(
                      'assets/images/bookingBackground.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.all(2.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBookingSection(
                    status: 'Pending',
                    bookings: _selectedBookings
                        .where((booking) => booking.status == 'pending')
                        .toList(),
                    emptyMessage: 'No pending bookings',
                    color: Colors.yellow.shade900,
                  ),
                  const SizedBox(height: 16),
                  _buildBookingSection(
                    status: 'Accepted',
                    bookings: _selectedBookings
                        .where((booking) => booking.status == 'confirmed')
                        .toList(),
                    emptyMessage: 'No accepted bookings',
                    color: Colors.blue.shade900,
                    isMarkAsDoneEnabled: true,
                  ),
                  const SizedBox(height: 16),
                  _buildBookingSection(
                    status: 'Done',
                    bookings: _selectedBookings
                        .where((booking) => booking.status == 'done')
                        .toList(),
                    emptyMessage: 'No completed bookings',
                    color: Colors.green.shade900,
                    isMarkAsDoneEnabled: false,
                  ),
                  const SizedBox(height: 16),
                  _buildBookingSection(
                    status: 'Declined',
                    bookings: _selectedBookings
                        .where((booking) => booking.status == 'declined')
                        .toList(),
                    emptyMessage: 'No declined bookings',
                    color: Colors.red.shade900,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
