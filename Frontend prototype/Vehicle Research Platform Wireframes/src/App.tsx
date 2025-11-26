import React, { useState } from 'react';
import { Header } from './components/Header';
import { Footer } from './components/Footer';
import { HomePage } from './components/HomePage';
import { ListingPage } from './components/ListingPage';
import { VehicleDetailPage } from './components/VehicleDetailPage';
import { UsedVehicleListingPage } from './components/UsedVehicleListingPage';
import { UsedVehicleDetailPage } from './components/UsedVehicleDetailPage';
import { ComparisonPage } from './components/ComparisonPage';
import { InsightsPage } from './components/InsightsPage';
import { NewsPage } from './components/NewsPage';
import { ServicesPage } from './components/ServicesPage';
import { ForumPage } from './components/ForumPage';
import { UserProfilePage } from './components/UserProfilePage';

type Page = 
  | 'home' 
  | 'listing' 
  | 'detail' 
  | 'used-listing' 
  | 'used-detail'
  | 'compare' 
  | 'insights' 
  | 'news'
  | 'services'
  | 'forum'
  | 'profile';

export default function App() {
  const [currentPage, setCurrentPage] = useState<Page>('home');
  const [selectedVehicleId, setSelectedVehicleId] = useState<string>('1');

  const handleNavigate = (page: string, vehicleId?: string) => {
    setCurrentPage(page as Page);
    if (vehicleId) {
      setSelectedVehicleId(vehicleId);
    }
    // Scroll to top on navigation
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  return (
    <div className="min-h-screen flex flex-col bg-white">
      <Header currentPage={currentPage} onNavigate={handleNavigate} />
      
      <main className="flex-1">
        {currentPage === 'home' && <HomePage onNavigate={handleNavigate} />}
        {currentPage === 'listing' && <ListingPage onNavigate={handleNavigate} />}
        {currentPage === 'detail' && (
          <VehicleDetailPage vehicleId={selectedVehicleId} onNavigate={handleNavigate} />
        )}
        {currentPage === 'used-listing' && <UsedVehicleListingPage onNavigate={handleNavigate} />}
        {currentPage === 'used-detail' && (
          <UsedVehicleDetailPage vehicleId={selectedVehicleId} onNavigate={handleNavigate} />
        )}
        {currentPage === 'compare' && <ComparisonPage onNavigate={handleNavigate} />}
        {currentPage === 'insights' && <InsightsPage onNavigate={handleNavigate} />}
        {currentPage === 'news' && <NewsPage onNavigate={handleNavigate} />}
        {currentPage === 'services' && <ServicesPage onNavigate={handleNavigate} />}
        {currentPage === 'forum' && <ForumPage onNavigate={handleNavigate} />}
        {currentPage === 'profile' && <UserProfilePage onNavigate={handleNavigate} />}
      </main>

      <Footer />
    </div>
  );
}
