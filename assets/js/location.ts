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
  bookings: Booking[];
}

const formatDate = (date: string): string => {
  const d = new Date(date);
  return `${d.getHours()}:${d.getMinutes()}`;
};

const renderBooking = (parent: Element, { label, start, end }: Booking) => {
  createElement('div', parent, {
    class: 'booking',
    text: `${label}: ${formatDate(start)} - ${formatDate(end)}`,
  });
};

const toISO = (date: HTMLInputElement): string =>
  new Date(date.value).toISOString();

const renderBookingCreate = (
  token: string,
  parent: Element,
  bookable: Bookable,
) => {
  const form = createElement('form', parent, {});
  const label = createElement('input', form, {
    type: 'text',
  });
  const start = createElement('input', form, {
    type: 'datetime-local',
  });
  const end = createElement('input', form, {
    type: 'datetime-local',
  });

  createElement('button', form, { text: 'Add' });
  form.addEventListener('submit', async (e) => {
    e.preventDefault();
    queryGraph(
      token,
      `mutation {
        createBooking(label: "${label.value}", start: "${toISO(
        start,
      )}" end: "${toISO(end)}" bookableId: ${bookable.id}) {
          label id
        }
      }`,
    );
  });
};

const renderBookable = (token: string, parent: Element, bookable: Bookable) => {
  const card = createElement('div', parent, { class: 'bookable-item' });
  createElement('div', card, { class: 'label', text: bookable.name });
  bookable.bookings.forEach((b) => renderBooking(card, b));
  renderBookingCreate(token, card, bookable);
};

const renderBookables = (
  token: string,
  parent: Element,
  bookables: Bookable[],
) => {
  const bookableGrid = createElement('div', parent, { class: 'bookable-grid' });
  bookables.forEach((b) => renderBookable(token, bookableGrid, b));
};

export const queryForLocation = async (
  token: string,
  locationId: string,
): Promise<Location> => {
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
  renderBookables(token, parent, bookables);
};
