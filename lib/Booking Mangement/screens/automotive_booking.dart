import 'package:autocare_automotiveshops/Authentication/Widgets/snackBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

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
  Map<DateTime, List<BookingModel>> _events = {};
  DateTime _selectedDate = DateTime.now();
  List<BookingModel> _selectedBookings = [];
  bool isLoading = false;
  String? currentBookingId;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
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

  Future<void> markBookingAsDone(BookingModel booking) async {
    try {
      await _bookingService.updateBookingStatus(booking.bookingId!, 'done');

      logger.i('Booking marked as done: ${booking.bookingId}');

      setState(() {
        booking.status = 'done';
      });

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
      await _bookingService.updateBookingStatus(
          booking.bookingId!, 'confirmed');
      logger.i('Booking accepted: ${booking.bookingId}');

      setState(() {
        booking.status = 'confirmed';
      });

      Navigator.pop(context);

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
                                booking.totalPrice.toString(),
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
                          const SizedBox(height: 16),
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
                                  color: Colors.grey,
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
          Container(
            width: double.infinity,
            color: color,
            padding: const EdgeInsets.all(8.0),
            child: Text(
              status,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          bookings.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    emptyMessage,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
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
                          vertical: 8.0, horizontal: 12.0),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking.selectedService.join(', ').toUpperCase(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.calendar_today,
                                              color: Colors.blue, size: 20),
                                          const SizedBox(width: 5),
                                          Text(
                                            '${booking.bookingDate}, ${booking.bookingTime}',
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      // Total Price
                                      Row(
                                        children: [
                                          const Icon(Icons.attach_money,
                                              color: Colors.blue, size: 20),
                                          const SizedBox(width: 5),
                                          Text(
                                            booking.totalPrice.toString(),
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      // Full Name
                                      Row(
                                        children: [
                                          const Icon(Icons.person,
                                              color: Colors.blue, size: 20),
                                          const SizedBox(width: 5),
                                          Text(
                                            booking.fullName,
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      // Status
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
                                              text:
                                                  '${booking.status?.toUpperCase()}',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.orange,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isMarkAsDoneEnabled)
                                  SizedBox(
                                    width: 100,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        await markBookingAsDone(booking);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: Colors.green,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12.0),
                                      ),
                                      child: const Text(
                                        'Done?',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
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
                const SizedBox(height: 45),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _selectedDate,
                    calendarFormat: CalendarFormat.month,
                    selectedDayPredicate: (day) =>
                        isSameDay(_selectedDate, day),
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
                        size: 35,
                      ),
                      rightChevronIcon: const Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                        size: 35,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade900,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16)),
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
                        border:
                            Border.all(color: Colors.grey.shade300, width: 1),
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
                      cellMargin: const EdgeInsets.all(6),
                      todayTextStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      selectedTextStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      weekendTextStyle: TextStyle(
                        color: Colors.red.shade300,
                        fontSize: 16,
                      ),
                      defaultTextStyle: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBookingSection(
                    status: 'Pending',
                    bookings: _selectedBookings
                        .where((booking) => booking.status == 'pending')
                        .toList(),
                    emptyMessage: 'No pending bookings',
                    color: Colors.orange.shade100,
                  ),
                  const SizedBox(height: 16),
                  _buildBookingSection(
                    status: 'Accepted',
                    bookings: _selectedBookings
                        .where((booking) => booking.status == 'confirmed')
                        .toList(),
                    emptyMessage: 'No accepted bookings',
                    color: Colors.blue.shade100,
                    isMarkAsDoneEnabled: true,
                  ),
                  const SizedBox(height: 16),
                  _buildBookingSection(
                    status: 'Done',
                    bookings: _selectedBookings
                        .where((booking) => booking.status == 'done')
                        .toList(),
                    emptyMessage: 'No completed bookings',
                    color: Colors.green.shade100,
                  ),
                  const SizedBox(height: 16),
                  _buildBookingSection(
                    status: 'Declined',
                    bookings: _selectedBookings
                        .where((booking) => booking.status == 'declined')
                        .toList(),
                    emptyMessage: 'No declined bookings',
                    color: Colors.red.shade100,
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
