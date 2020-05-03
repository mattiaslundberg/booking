export const fetchJson = async (
  url: string,
  body: Record<string, string>
): Promise<Record<string, string>> => {
  return (
    await fetch(url, {
      method: "POST",
      headers: {
        Accept: "application/json",
        "Content-Type": "application/json",
      },
      body: JSON.stringify(body),
    })
  ).json();
};

export const queryGraph = async (
  token: string,
  query: string
): Promise<Record<string, any>> => {
  return (
    await fetch("/graphql", {
      method: "POST",
      headers: {
        Accept: "application/json",
        "Content-Type": "application/graphql",
        "x-user-token": token,
      },
      body: query,
    })
  ).json();
};
