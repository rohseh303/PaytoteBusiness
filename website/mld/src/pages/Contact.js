import React, { useState } from 'react';
import NavBar from '../components/Navbar/NavBar';
import Footer from '../components/Footer';
import {useDocTitle} from '../components/CustomHook';
import axios from 'axios';
// import emailjs from 'emailjs-com';
import Notiflix from 'notiflix';

const Contact = () => {
    useDocTitle('MLD | Molad e Konsult - Send us a message')

    return (
        <>
            <div>
                <NavBar />
            </div>
            
            <div>
                Hello
            </div>

            <Footer />
        </>


    )
}

export default Contact;