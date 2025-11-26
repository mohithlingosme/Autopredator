import Link from 'next/link';

const stats = [
  { label: 'Fleet vehicles under watch', value: '120+' },
  { label: 'Predictive maintenance hits', value: '98%' },
  { label: 'AI-assisted decisions', value: '4x faster' }
];

const highlights = [
  'Connect your React dashboard securely to the Django API via jwt-authentication.',
  'Leverage predictive maintenance to schedule service before downtime.',
  'Monitor analytics and cost trends that feed directly into fleet decisions.'
];

export default function HomePage() {
  return (
    <div className="min-h-screen bg-charcoal text-white">
      <section className="container mx-auto px-4 py-20 space-y-10">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 items-center">
          <div className="space-y-6">
            <p className="text-xs uppercase tracking-[0.5em] text-blue/60">Autopredator</p>
            <h1 className="text-5xl font-bold">Vehicle Intelligence. Predictable Outcomes.</h1>
            <p className="text-lg text-white/80 leading-relaxed">
              Autopredator unifies your fleet inventory, maintenance logs, AI predictions, and monetization
              flows into a single SaaS platform built with React, Next.js, and Django REST.
            </p>
            <div className="flex flex-wrap gap-4">
              <Link href="/dashboard" className="btn-primary px-6 py-3">
                View Dashboard
              </Link>
              <Link href="/login" className="btn-secondary px-6 py-3">
                Sign in
              </Link>
            </div>
          </div>
          <div className="rounded-3xl border border-white/20 bg-white/5 p-8 space-y-6">
            <h2 className="text-xl font-semibold text-white/90">Highlights</h2>
            <ul className="space-y-3 text-sm text-white/80">
              {highlights.map(item => (
                <li key={item} className="flex gap-3 items-start">
                  <span className="text-blue">•</span>
                  <span>{item}</span>
                </li>
              ))}
            </ul>
          </div>
        </div>

        <section className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {stats.map(entry => (
            <div key={entry.label} className="rounded-3xl border border-white/20 bg-white/5 p-6 text-center">
              <p className="text-2xl font-semibold">{entry.value}</p>
              <p className="text-xs uppercase tracking-[0.4em] text-white/70 mt-2">{entry.label}</p>
            </div>
          ))}
        </section>

        <section className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <article className="rounded-3xl border border-blue/60 p-6 bg-gradient-to-br from-blue to-indigo text-white">
            <h3 className="text-xl font-semibold">AI Predictions</h3>
            <p className="text-sm mt-2 text-white/80">
              Use the `/api/predict/` endpoint to forecast next service dates using mileage, vehicle type, and last
              service data.
            </p>
          </article>
          <article className="rounded-3xl border border-white/20 p-6 bg-white/10 text-white">
            <h3 className="text-xl font-semibold">Notification & Email</h3>
            <p className="text-sm mt-2 text-white/80">
              Django sends reminders automatically for services and document expirations using the built-in email API.
            </p>
          </article>
          <article className="rounded-3xl border border-white/20 p-6 bg-white/10 text-white">
            <h3 className="text-xl font-semibold">Analytics & Monetization</h3>
            <p className="text-sm mt-2 text-white/80">
              Track API usage, feature adoption, and monetization plans while protecting traffic with JWT and analytics.
            </p>
          </article>
        </section>
      </section>
    </div>
  );
}
