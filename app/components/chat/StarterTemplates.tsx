import React from 'react';
import type { Template } from '~/types/template';
import { STARTER_TEMPLATES } from '~/utils/constants';

interface FrameworkLinkProps {
  template: Template;
}

const FrameworkLink: React.FC<FrameworkLinkProps> = ({ template }) => (
  <a
    href={`/git?url=https://github.com/${template.githubRepo}.git`}
    data-state="closed"
    data-discover="true"
    className="items-center justify-center"
  >
    <div
      className={`inline-block ${template.icon} w-8 h-8 text-4xl transition-theme opacity-25 hover:opacity-100 hover:text-purple-500 dark:text-white dark:opacity-50 dark:hover:opacity-100 dark:hover:text-purple-400 transition-all`}
      title={template.label}
    />
  </a>
);

const StarterTemplates: React.FC = () => {
  // Debug: Log available templates and their icons
  React.useEffect(() => {
    console.log(
      'Available templates:',
      STARTER_TEMPLATES.map((t) => ({ name: t.name, icon: t.icon })),
    );
  }, []);

  return (
    <div className="flex flex-col items-center gap-4">
      <div className="flex flex-col items-center gap-2">
        <a href="https://www.facebook.com/mdsharansifat/" target="_blank" rel="noopener noreferrer" className="px-4 py-2 rounded-md text-white font-medium hover:opacity-90 transition-opacity" style={{ backgroundColor: '#b20ee1' }}>Follow On Facebook</a>
        <span className="text-sm text-gray-500">@ Copyrights 2025, BAUST DEV By <a href="https://wa.me/8801751465955?text=Hey%20Sharan%20Sifat,%20I%20come%20from%20BAUST%20DEV" target="_blank" rel="noopener noreferrer" className="text-blue-500 hover:text-blue-600">Sharan Sifat</a> (Python Developer)</span>
      </div>
      <div className="flex justify-center">
        <div className="flex w-70 flex-wrap items-center justify-center gap-4">
          {STARTER_TEMPLATES.map((template) => (
            <FrameworkLink key={template.name} template={template} />
          ))}
        </div>
      </div>
    </div>
  );
};

export default StarterTemplates;
