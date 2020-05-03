import "../css/app.scss";
import "phoenix_html";
import { renderLogin } from "./login";
import { getToken, saveToken } from "./storage_helpers";
import { queryGraph } from "./http_helpers";
import { createElement, clearElement } from "./dom_helpers";
import { renderLocation } from "./location";

interface Location {
  id: number;
  name: string;
}

const renderLocationSelector = (
  token: string,
  parent: Element,
  locations: Location[]
) => {
  clearElement(parent);
  const selector = createElement("select", parent, {});
  const locationContainer = createElement("div", parent, {
    classList: "location",
  });

  locations.forEach((l) => {
    createElement("option", selector, { value: `${l.id}`, text: l.name });
  });

  selector.addEventListener("change", () => {
    renderLocation(selector.value, locationContainer, token);
  });

  renderLocation(selector.value, locationContainer, token);
};

const renderApp = async (parent: Element, token: string) => {
  const locationData = await queryGraph(
    token,
    "query { locations { id name } }"
  );
  const locations: Location[] = locationData.data.locations;
  renderLocationSelector(token, parent, locations);
};

const main = async () => {
  const container = document.getElementById("app-container");
  let token = getToken();
  if (!token) {
    token = await renderLogin(container);
    saveToken(token);
  }
  renderApp(container, token);
};

main();
