"use client";

import React from "react";

const INTEREST_OPTIONS = [
  "Academics",
  "Career guidance",
  "Mental health",
  "Research",
  "Placements",
  "Entrepreneurship",
  "Soft skills",
];

interface InterestSelectorProps {
  selectedInterests: string[];
  onChange: (interests: string[]) => void;
}

export default function InterestSelector({
  selectedInterests,
  onChange,
}: InterestSelectorProps) {
  const toggleInterest = (interest: string) => {
    let updatedInterests: string[];
    if (selectedInterests.includes(interest)) {
      updatedInterests = selectedInterests.filter((item) => item !== interest);
    } else {
      updatedInterests = [...selectedInterests, interest];
    }
    onChange(updatedInterests);
  };

  return (
    <div className="interest-container">
      <h3 className="interest-header">Areas of interest</h3>
      <div className="chip-group">
        {INTEREST_OPTIONS.map((interest) => {
          const isSelected = selectedInterests.includes(interest);
          return (
            <button
              key={interest}
              type="button"
              className={`chip ${isSelected ? "selected" : ""}`}
              onClick={() => toggleInterest(interest)}
            >
              {interest}
            </button>
          );
        })}
      </div>
    </div>
  );
}
