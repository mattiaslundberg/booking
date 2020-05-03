import { clearElement, createElement } from "./dom_helpers";
import { queryGraph } from "./http_helpers";

interface Bookable {
  id: number;
  name: string;
}

const renderBookables = (parent: Element, bookables: Bookable[]) => {
  bookables.forEach((b) => {
    createElement("div", parent, { text: b.name });
  });
};

export const renderLocation = async (
  locationId: string,
  parent: Element,
  token: string
) => {
  clearElement(parent);

  const locationData = await queryGraph(
    token,
    `query { location(id: ${locationId}) { name bookables { id name } } }`
  );

  createElement("div", parent, { text: locationData.data.location.name });
  renderBookables(parent, locationData.data.location.bookables);
};
