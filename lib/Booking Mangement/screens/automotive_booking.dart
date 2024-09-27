import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

import '../models/booking_model.dart';
import '../services/booking_services.dart';
import '../widgets/bookingButton.dart'; // Assuming you have this widget for the Accept/Decline buttons

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
  bool isLoading = false; // Track loading state
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
        // Parse and normalize the booking date
        DateTime bookingDate =
            DateFormat('dd/MM/yyyy').parse(booking.bookingDate);
        DateTime normalizedDate =
            _normalizeDate(bookingDate); // Normalize the date here

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
      _events = groupedBookings; // Store the grouped bookings
      logger.i('EVENTS: $_events');
      _selectedBookings = _events[_normalizeDate(_selectedDate)] ?? [];
      logger.i('SELECTED BOOKINGS: $_selectedBookings');
    });
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // Show booking details in a modal when a date is clicked
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
                                  fontSize: 16, fontWeight: FontWeight.w600),
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
                      Text(
                        'Car: ${booking.carBrand} ${booking.carModel}, Year: ${booking.carYear}',
                      ),
                      Text('Fuel Type: ${booking.fuelType}'),
                      Text('Transmission: ${booking.transmission}'),
                      const SizedBox(height: 16),
                      // Display status if currently processing or loading
                      if (isLoading == true && currentBookingId == booking.bookingId)
                        const Center(child: CircularProgressIndicator())
                      else if (booking.status != 'pending')
                        Text('Status: ${booking.status}',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold))
                      else if(isLoading == false)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            BookingButton(
                              text: 'Decline',
                              color: Colors.grey,
                              padding: 5.0,
                              onTap: () async {
                                setState(() {
                                  isLoading = true; // Set loading state
                                  currentBookingId = booking.bookingId; // Track the booking being processed
                                });
                                await _bookingService.updateBookingStatus(
                                    booking.bookingId!, 'declined');
                                logger.i('Booking declined: ${booking.bookingId}');
                                Future.delayed(const Duration(seconds: 5), () {
                                  setState(() {
                                    isLoading = false;
                                  });
                                });
                              },
                            ),
                          BookingButton(
                            text: 'Accept',
                            color: Colors.orange,
                            padding: 5.0,
                            onTap: () async {
                              setState(() {
                                isLoading = true; // Set loading state
                                currentBookingId = booking.bookingId; // Track the booking being processed
                              });
                              await _bookingService.updateBookingStatus(
                                  booking.bookingId!, 'confirmed');
                              logger.i('Booking accepted: ${booking.bookingId}');
                              Future.delayed(const Duration(seconds: 5), () {
                                setState(() {
                                  isLoading = false; // Reset loading state
                                });
                              });
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
    }
    );
  }

  // Build markers for days with events (bookings)
  Widget _buildEventMarker(List<BookingModel> bookings) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.orange
            .shade900, // Marker color, you can change based on booking status
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bookings',
              style: TextStyle(fontWeight: FontWeight.w900)),
          backgroundColor: Colors.grey.shade300,
          bottom: TabBar(
            tabs: [
              Tab(
                child: Text(
                  'Calendar View',
                  style: TextStyle(
                    fontSize: 16, // Custom font size
                    fontWeight: FontWeight.bold, // Custom font weight
                    color: Colors.orange.shade900, // Custom text color
                  ),
                ),
              ),
              Tab(
                child: Text(
                  'Bookings Today' ,
                  style: TextStyle(
                    fontSize: 16, // Custom font size
                    fontWeight: FontWeight.bold, // Custom font weight
                    color: Colors.orange.shade900, // Custom text color
                  ),
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Calendar View Tab
            Column(
              children: [
                // Adding padding around the calendar for better visual spacing
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _selectedDate,
                    calendarFormat: CalendarFormat.month,
                    selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDate = _normalizeDate(selectedDay); // Normalize selected date
                        _selectedBookings = _events[_normalizeDate(selectedDay)] ?? []; // Ensure consistent key
                        if (_selectedBookings.isNotEmpty) {
                          _showBookingDetailsModal(_selectedBookings); // Show details if bookings exist
                        }
                      });
                    },
                    eventLoader: (day) {
                      return _events[_normalizeDate(day)] ?? []; // Normalize the key when accessing
                    },
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, date, events) {
                        if (events.isNotEmpty) {
                          return Positioned(
                            bottom: 1,
                            child: _buildEventMarker(events as List<BookingModel>),
                          );
                        }
                        return null;
                      },
                    ),
                    headerStyle: const HeaderStyle(
                      titleCentered: true, // Center the title for better readability
                      titleTextStyle: TextStyle(
                        fontSize: 22, // Increased font size for better readability
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // Darker color for better contrast
                      ),
                      formatButtonVisible: false, // Hide format button (month/week)
                      leftChevronIcon: Icon(
                        Icons.chevron_left,
                        color: Colors.blue, // Customize left arrow
                        size: 28, // Larger arrow for easier navigation
                      ),
                      rightChevronIcon: Icon(
                        Icons.chevron_right,
                        color: Colors.blue, // Customize right arrow
                        size: 28, // Larger arrow for easier navigation
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orangeAccent, // Subtle background color for the header
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                    ),
                    calendarStyle: CalendarStyle(
                      selectedDecoration: BoxDecoration(
                        color: Colors.blue, // Color for the selected day
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      todayDecoration: BoxDecoration(
                        color: Colors.orange, // Highlight today's date
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      defaultDecoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade300, width: 1), // Border around normal days
                      ),
                      weekendDecoration: BoxDecoration(
                        color: Colors.grey.shade200, // Slightly highlight weekends
                        shape: BoxShape.circle,
                      ),
                      markerDecoration: BoxDecoration(
                        color: Colors.red, // Marker color for events
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
                        color: Colors.transparent, // Keep outside days transparent
                      ),
                      cellMargin: const EdgeInsets.all(6), // Space between the day cells for a cleaner look
                      todayTextStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // White text for today's date
                      ),
                      selectedTextStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // White text for selected day
                      ),
                      weekendTextStyle: TextStyle(
                        color: Colors.red.shade300, // Make weekend text more subtle
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
            // Progress Tracking Tab (Display the List of Bookings)
            Column(
              children: [
                // Title for the list
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    'Bookings for Selected Date',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade900,
                    ),
                  ),
                ),
                // List of bookings for the selected date
                Expanded(
                  child: _selectedBookings.isEmpty
                      ? const Center(child: Text('No bookings for this date'))
                      : ListView.builder(
                    itemCount: _selectedBookings.length,
                    itemBuilder: (context, index) {
                      BookingModel booking = _selectedBookings[index];
                      return ListTile(
                        title: Text(booking.selectedService.join(', ')),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${booking.bookingDate} ${booking.bookingTime}'),
                            Text('${booking.carBrand} ${booking.carModel}'), // Display selected service
                            Text('Status: ${booking.status}'), // Display booking status
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
