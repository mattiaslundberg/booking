export const getToken = (): string => localStorage.getItem("bookingToken");

export const saveToken = (token: string) =>
  localStorage.setItem("bookingToken", token);
