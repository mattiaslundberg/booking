import { clearElement, createElement } from './dom_helpers';
import { queryGraph } from './http_helpers';

interface Bookable {
  id: number;
  name: string;
}

const renderBookable = (parent: Element, bookable: Bookable) => {
  const card = createElement('div', parent, { class: 'bookable-item' });
  createElement('div', card, { class: 'label', text: bookable.name });

  // if (bookable.currentBooking) {

  // }

  // if (bookable.nextBooking) {

  // }
};

const renderBookables = (parent: Element, bookables: Bookable[]) => {
  const bookableGrid = createElement('div', parent, { class: 'bookable-grid' });
  bookables.forEach((b) => renderBookable(bookableGrid, b));
};

export const renderLocation = async (
  locationId: string,
  parent: Element,
  token: string,
) => {
  clearElement(parent);

  const locationData = await queryGraph(
    token,
    `query { location(id: ${locationId}) { name bookables { id name } } }`,
  );

  createElement('div', parent, { text: locationData.data.location.name });
  renderBookables(parent, locationData.data.location.bookables);
};
