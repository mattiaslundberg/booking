import '../css/app.scss';
import 'phoenix_html';
import { renderLogin } from './login';
import { getToken, saveToken, restoreToken } from './storage_helpers';
import { queryGraph } from './http_helpers';
import { createElement, clearElement } from './dom_helpers';
import { renderLocation } from './location';

interface Location {
  id: number;
  name: string;
}

const renderLocationSelector = (
  token: string,
  parent: Element,
  locations: Location[],
) => {
  clearElement(parent);
  const selector = createElement('select', parent, {});
  const locationContainer = createElement('div', parent, {
    classList: 'location',
  });

  locations.forEach((l) => {
    createElement('option', selector, { value: `${l.id}`, text: l.name });
  });

  selector.addEventListener('change', () => {
    renderLocation(selector.value, locationContainer, token);
  });

  renderLocation(selector.value, locationContainer, token);
};

const renderApp = async (parent: Element, token: string) => {
  try {
    const locationData = await queryGraph(
      token,
      'query { locations { id name } }',
    );
    const locations: Location[] = locationData.data.locations;
    renderLocationSelector(token, parent, locations);
  } catch {
    restoreToken();
    const newToken = await maybeDoLogin(parent, null);
    renderApp(parent, newToken);
  }
};

const maybeDoLogin = async (
  container: Element,
  token?: string,
): Promise<string> => {
  if (!token) {
    token = await renderLogin(container);
    saveToken(token);
  }
  return token;
};

const main = async () => {
  const container = document.getElementById('app-container');
  const token = getToken();
  const newToken = await maybeDoLogin(container, token);
  renderApp(container, newToken);
};

main();
