import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Sports Science App",
  description: "Manage athlete time trial data and training sessions",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className="antialiased">{children}</body>
    </html>
  );
}
