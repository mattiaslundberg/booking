import "../css/app.scss";
import "phoenix_html";
import { renderLogin } from "./login";
import { getToken, saveToken } from "./storage_helpers";
import { queryGraph } from "./http_helpers";

const renderApp = async (parent: Element, token: string) => {
  const locations = await queryGraph(token, "query { locations { id name } }");
  console.warn(locations);
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
