export function createElement(
  elementType: "input",
  parent: Element,
  attrs: Record<string, string>
): HTMLInputElement;

export function createElement(
  elementType: "select",
  parent: Element,
  attrs: Record<string, string>
): HTMLSelectElement;

export function createElement(
  elementType: string,
  parent: Element,
  attrs: Record<string, string>
): Element;

export function createElement(
  elementType: string,
  parent: Element,
  attrs: Record<string, string>
): Element {
  const elm = document.createElement(elementType);
  parent.appendChild(elm);

  Object.entries(attrs).forEach(([key, value]: Array<string>) => {
    if (key === "text") {
      elm.innerText = value;
    } else {
      elm.setAttribute(key, value);
    }
  });

  return elm;
};
