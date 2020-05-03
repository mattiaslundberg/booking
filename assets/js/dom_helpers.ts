export const createElement = (
  elementType: string,
  parent: Element,
  attrs: Record<string, string>
): Element => {
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
