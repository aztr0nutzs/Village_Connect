import React, { useState, useEffect } from 'react';
import { theme } from '../themes';
import { Button, Navigation } from '../components';

// Event interface
interface Event {
  id: number;
  title: string;
  description: string;
  date: string;
  time: string;
  location: string;
  category: 'social' | 'educational' | 'fitness' | 'entertainment' | 'volunteer';
  capacity: number;
  registered: number;
  isRegistered: boolean;
}

// Events screen component
const Events: React.FC = () => {
  const [filter, setFilter] = useState<string>('all');

  // Sample events data
  const [events, setEvents] = useState<Event[]>([
    {
      id: 1,
      title: 'Monthly Community Meeting',
      description: 'Join us for our monthly community meeting where we discuss upcoming events, share announcements, and connect with neighbors.',
      date: '2024-01-25',
      time: '2:00 PM - 4:00 PM',
      location: 'Clubhouse Main Hall',
      category: 'social',
      capacity: 100,
      registered: 45,
      isRegistered: false,
    },
    {
      id: 2,
      title: 'Senior Fitness Class',
      description: 'Gentle exercise class designed for seniors. Includes chair exercises, light stretching, and balance activities.',
      date: '2024-01-26',
      time: '10:00 AM - 11:00 AM',
      location: 'Fitness Center',
      category: 'fitness',
      capacity: 20,
      registered: 18,
      isRegistered: true,
    },
    {
      id: 3,
      title: 'Computer Basics Workshop',
      description: 'Learn the basics of using computers and smartphones. Topics include email, internet browsing, and video calling.',
      date: '2024-01-28',
      time: '1:00 PM - 3:00 PM',
      location: 'Computer Lab',
      category: 'educational',
      capacity: 15,
      registered: 12,
      isRegistered: false,
    },
    {
      id: 4,
      title: 'Movie Night: Classic Films',
      description: 'Enjoy a screening of classic movies from the golden age of cinema. Popcorn and refreshments provided.',
      date: '2024-01-30',
      time: '7:00 PM - 9:00 PM',
      location: 'Recreation Center',
      category: 'entertainment',
      capacity: 80,
      registered: 67,
      isRegistered: false,
    },
    {
      id: 5,
      title: 'Volunteer Opportunity: Food Bank',
      description: 'Help sort and pack food donations for local families in need. Training provided, all skill levels welcome.',
      date: '2024-02-02',
      time: '9:00 AM - 12:00 PM',
      location: 'Community Center',
      category: 'volunteer',
      capacity: 25,
      registered: 8,
      isRegistered: false,
    },
  ]);

  // Filter events based on selected category
  const filteredEvents = filter === 'all'
    ? events
    : events.filter(event => event.category === filter);

  // Handle event registration
  const handleRegistration = (eventId: number) => {
    setEvents(prevEvents =>
      prevEvents.map(event =>
        event.id === eventId
          ? {
              ...event,
              isRegistered: !event.isRegistered,
              registered: event.isRegistered
                ? event.registered - 1
                : event.registered + 1
            }
          : event
      )
    );
  };

  // Get category color
  const getCategoryColor = (category: string) => {
    switch (category) {
      case 'social': return theme.colors.primary;
      case 'educational': return theme.colors.info;
      case 'fitness': return theme.colors.success;
      case 'entertainment': return theme.colors.secondary;
      case 'volunteer': return theme.colors.warning;
      default: return theme.colors.primary;
    }
  };

  // Get category label
  const getCategoryLabel = (category: string) => {
    switch (category) {
      case 'social': return 'Social';
      case 'educational': return 'Educational';
      case 'fitness': return 'Fitness';
      case 'entertainment': return 'Entertainment';
      case 'volunteer': return 'Volunteer';
      default: return 'Other';
    }
  };

  return (
    <div
      style={{
        minHeight: '100vh',
        backgroundColor: theme.colors.background,
        fontFamily: theme.typography.fontFamily,
      }}
    >
      <Navigation />

      <main
        style={{
          maxWidth: '1200px',
          margin: '0 auto',
          padding: theme.spacing.xl,
        }}
      >
        {/* Header */}
        <div style={{ marginBottom: theme.spacing.xxxl }}>
          <h1
            style={{
              fontSize: theme.typography.fontSizes.xxl,
              fontWeight: theme.typography.fontWeights.bold,
              color: theme.colors.textPrimary,
              marginBottom: theme.spacing.lg,
            }}
          >
            Community Events
          </h1>
          <p
            style={{
              fontSize: theme.typography.fontSizes.lg,
              color: theme.colors.textSecondary,
              marginBottom: theme.spacing.xl,
            }}
          >
            Discover and register for upcoming community events in The Villages.
          </p>

          {/* Filter Buttons */}
          <div
            style={{
              display: 'flex',
              gap: theme.spacing.md,
              flexWrap: 'wrap',
              marginBottom: theme.spacing.xl,
            }}
          >
            {[
              { value: 'all', label: 'All Events' },
              { value: 'social', label: 'Social' },
              { value: 'educational', label: 'Educational' },
              { value: 'fitness', label: 'Fitness' },
              { value: 'entertainment', label: 'Entertainment' },
              { value: 'volunteer', label: 'Volunteer' },
            ].map(({ value, label }) => (
              <Button
                key={value}
                variant={filter === value ? 'primary' : 'secondary'}
                size="md"
                onClick={() => setFilter(value)}
              >
                {label}
              </Button>
            ))}
          </div>
        </div>

        {/* Events Grid */}
        <div
          style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fit, minmax(400px, 1fr))',
            gap: theme.spacing.xl,
          }}
        >
          {filteredEvents.map((event) => (
            <div
              key={event.id}
              style={{
                backgroundColor: theme.colors.card,
                border: `2px solid ${theme.colors.border}`,
                borderRadius: theme.components.card.borderRadius,
                padding: theme.components.card.padding,
                boxShadow: theme.shadows.sm,
                transition: theme.transitions.normal,
              }}
            >
              {/* Event Header */}
              <div style={{ marginBottom: theme.spacing.lg }}>
                <div
                  style={{
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'flex-start',
                    marginBottom: theme.spacing.md,
                  }}
                >
                  <h2
                    style={{
                      fontSize: theme.typography.fontSizes.xl,
                      fontWeight: theme.typography.fontWeights.bold,
                      color: theme.colors.textPrimary,
                      margin: 0,
                    }}
                  >
                    {event.title}
                  </h2>
                  <span
                    style={{
                      backgroundColor: getCategoryColor(event.category),
                      color: theme.colors.textInverse,
                      padding: `${theme.spacing.xs} ${theme.spacing.sm}`,
                      borderRadius: theme.borderRadius.sm,
                      fontSize: theme.typography.fontSizes.sm,
                      fontWeight: theme.typography.fontWeights.medium,
                    }}
                  >
                    {getCategoryLabel(event.category)}
                  </span>
                </div>

                <p
                  style={{
                    fontSize: theme.typography.fontSizes.md,
                    color: theme.colors.textSecondary,
                    lineHeight: theme.typography.lineHeights.normal,
                    margin: 0,
                  }}
                >
                  {event.description}
                </p>
              </div>

              {/* Event Details */}
              <div style={{ marginBottom: theme.spacing.xl }}>
                <div
                  style={{
                    display: 'grid',
                    gridTemplateColumns: '1fr 1fr',
                    gap: theme.spacing.md,
                    marginBottom: theme.spacing.lg,
                  }}
                >
                  <div>
                    <strong style={{ color: theme.colors.textPrimary }}>Date:</strong>
                    <div style={{ color: theme.colors.textSecondary }}>
                      {new Date(event.date).toLocaleDateString('en-US', {
                        weekday: 'long',
                        year: 'numeric',
                        month: 'long',
                        day: 'numeric',
                      })}
                    </div>
                  </div>
                  <div>
                    <strong style={{ color: theme.colors.textPrimary }}>Time:</strong>
                    <div style={{ color: theme.colors.textSecondary }}>{event.time}</div>
                  </div>
                  <div>
                    <strong style={{ color: theme.colors.textPrimary }}>Location:</strong>
                    <div style={{ color: theme.colors.textSecondary }}>{event.location}</div>
                  </div>
                  <div>
                    <strong style={{ color: theme.colors.textPrimary }}>Spots:</strong>
                    <div style={{ color: theme.colors.textSecondary }}>
                      {event.registered}/{event.capacity} registered
                    </div>
                  </div>
                </div>
              </div>

              {/* Registration Button */}
              <div style={{ textAlign: 'center' }}>
                <Button
                  variant={event.isRegistered ? 'success' : 'primary'}
                  size="lg"
                  onClick={() => handleRegistration(event.id)}
                  disabled={event.registered >= event.capacity && !event.isRegistered}
                >
                  {event.isRegistered
                    ? '✓ Registered'
                    : event.registered >= event.capacity
                      ? 'Event Full'
                      : 'Register Now'
                  }
                </Button>
              </div>
            </div>
          ))}
        </div>

        {/* Empty State */}
        {filteredEvents.length === 0 && (
          <div
            style={{
              textAlign: 'center',
              padding: theme.spacing.xxxl,
              color: theme.colors.textMuted,
            }}
          >
            <div style={{ fontSize: '64px', marginBottom: theme.spacing.xl }}>📅</div>
            <h3
              style={{
                fontSize: theme.typography.fontSizes.xl,
                marginBottom: theme.spacing.lg,
              }}
            >
              No events found
            </h3>
            <p style={{ fontSize: theme.typography.fontSizes.lg }}>
              Try selecting a different category or check back later for new events.
            </p>
          </div>
        )}
      </main>
    </div>
  );
};

export default Events;