export const getToken = (): string | null =>
  localStorage.getItem('bookingToken');

export const saveToken = (token: string) =>
  localStorage.setItem('bookingToken', token);

export const restoreToken = () => localStorage.removeItem('bookingToken');
