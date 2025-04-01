import React, { useEffect } from 'react';
import AOS from 'aos';
import 'aos/dist/aos.css';

const TestAOS = () => {
    useEffect(() => {
        // Initialization of AOS
        AOS.init();

        // Function to check the will-change property
        const checkWillChange = () => {
            // Get all elements with data-aos
            const aosElements = document.querySelectorAll('[data-aos]');
            
            console.log(`Found ${aosElements.length} elements with data-aos`);
            
            aosElements.forEach((element, index) => {
                // Tambahkan border pada elemen
                element.style.border = '2px dashed red';
                
                // Mengambil computed style
                const computedStyle = window.getComputedStyle(element);
                const willChange = computedStyle.getPropertyValue('will-change');
                
                console.log(`Element ${index + 1}:`, {
                    'data-aos': element.getAttribute('data-aos'),
                    'will-change': willChange,
                    'element': element.tagName,
                    'classes': element.className
                });
            });
        };

        // Run the check after AOS is initialized
        setTimeout(checkWillChange, 100);
    }, []);

    return (
        <>
            <style>
                {`
                    [data-aos] {
                        will-change: transform, opacity !important;
                    }
                `}
            </style>

           
        </>
    );
};

export default TestAOS;
