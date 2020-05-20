export const fetchJson = async (
  url: string,
  body: Record<string, string>,
): Promise<Record<string, string>> => {
  try {
    return (
      await fetch(url, {
        method: 'POST',
        headers: {
          Accept: 'application/json',
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(body),
      })
    ).json();
  } catch {
    return new Promise((_res, rej) => {
      rej('Failed to load');
    });
  }
};

export const queryGraph = async (
  token: string,
  query: string,
): Promise<Record<string, any>> => {
  try {
    return (
      await fetch('/graphql', {
        method: 'POST',
        headers: {
          Accept: 'application/json',
          'Content-Type': 'application/graphql',
          'x-user-token': token,
        },
        body: query,
      })
    ).json();
  } catch {
    return new Promise((_res, rej) => {
      rej('Failed to load');
    });
  }
};
