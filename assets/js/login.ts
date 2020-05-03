import { createElement } from "./dom_helpers";
import { fetchJson } from "./http_helpers";

export const renderLogin = (parent: Element): Promise<string> => {
  const form = createElement("form", parent, {});
  const emailInput = createElement("input", form, {
    type: "email",
    name: "email",
  });
  const passInput = createElement("input", form, {
    type: "password",
    name: "password",
  });
  createElement("button", form, { text: "Login" });

  return new Promise(async (resolve) => {
    form.addEventListener("submit", async (e) => {
      e.preventDefault();
      const response = await fetchJson("/login", {
        email: emailInput.value,
        password: passInput.value,
      });

      const token: string = response.token;
      resolve(token);
    });
  });
};
