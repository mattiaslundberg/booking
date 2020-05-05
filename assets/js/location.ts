import { clearElement, createElement } from './dom_helpers';
import { queryGraph } from './http_helpers';

interface Location {
  name: string;
  bookables: Bookable[];
}

interface Booking {
  id: number;
  label: string;
  start: string;
  end: string;
}

interface Bookable {
  id: number;
  name: string;
  bookings: Booking[],
}

const formatDate = (date: string) : string => {
  const d = new Date(date);
  return `${d.getHours()}:${d.getMinutes()}`;
};

const renderBooking = (parent: Element, { label, start, end }: Booking) => {
  createElement('div', parent, { class: 'booking', text: `${label}: ${formatDate(end)} - ${formatDate(end)}` });
};

const renderBookable = (parent: Element, { name, bookings }: Bookable) => {
  const card = createElement('div', parent, { class: 'bookable-item' });
  createElement('div', card, { class: 'label', text: name });
  bookings.forEach(b => renderBooking(card, b));
};

const renderBookables = (parent: Element, bookables: Bookable[]) => {
  const bookableGrid = createElement('div', parent, { class: 'bookable-grid' });
  bookables.forEach(b => renderBookable(bookableGrid, b));
};

export const queryForLocation = async (token: string, locationId: string) : Promise<Location> => {
  const locationData = await queryGraph(
    token,
    `query { location(id: ${locationId}) { name bookables { id name bookings { id label start end } } } }`,
  );
  return locationData.data.location as Location;
};

export const renderLocation = async (
  locationId: string,
  parent: Element,
  token: string,
) => {
  clearElement(parent);

  const { name, bookables } = await queryForLocation(token, locationId);
  createElement('div', parent, { text: name });
  renderBookables(parent, bookables);
};
