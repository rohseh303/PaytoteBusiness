import React, { useState, useEffect } from 'react';

const Authorize = () => {
  const applicationId = process.env.REACT_APP_SQ_APPLICATION_ID;
  console.log("applicationId: ", applicationId)
  const environment = process.env.REACT_APP_SQ_ENVIRONMENT;
//   const applicationSecret = process.env.REACT_APP_SQ_APPLICATION_SECRET;
  const baseUrl = environment === "production" ? "https://connect.squareup.com" : "https://connect.squareupsandbox.com";


  const [state, setState] = useState('');
  useEffect(() => {
    // Generate a secure, random token
    const generateStateToken = () => {
      // Simple implementation - for production use a more robust method
      return [...Array(30)].map(() => Math.random().toString(36)[2]).join('');
    };

    setState(generateStateToken());
  }, []);
  
  const url = `${baseUrl}/oauth2/authorize?client_id=${applicationId}&scope=PAYMENTS_READ&session=false&state=${state}`;
  
  console.log("url: ", url)
  return (
    <div className='wrapper'>
      <a className='btn' href={url}>
        <strong>Authorize</strong>
      </a>
    </div>
  );
};

export default Authorize;
