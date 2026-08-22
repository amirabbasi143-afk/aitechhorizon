// Add a blur effect to navbar on scroll
window.addEventListener('scroll', () => {
    const nav = document.getElementById('navbar');
    if (window.scrollY > 50) {
        nav.style.padding = '15px 50px';
        nav.style.background = 'rgba(255, 255, 255, 0.98)';
    } else {
        nav.style.padding = '20px 50px';
        nav.style.background = 'rgba(255, 255, 255, 0.95)';
    }
});

// Simple animation for elements as they enter viewport
const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if(entry.isIntersecting) {
            entry.target.style.opacity = '1';
            entry.target.style.transform = 'translateY(0)';
        }
    });
}, { threshold: 0.1 });

// Select elements to animate
document.querySelectorAll('.card').forEach(card => {
    card.style.opacity = '0';
    card.style.transform = 'translateY(30px)';
    card.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
    observer.observe(card);
});

// Slider Logic
let slideIndex = 1;
let slideInterval;

function initSlider() {
    let slides = document.getElementsByClassName("slide");
    if (!slides.length) return; // Only run if slider exists on page

    showSlides(slideIndex);
    startSlideTimer();

    const prevBtn = document.querySelector('.prev-btn');
    const nextBtn = document.querySelector('.next-btn');

    if (prevBtn && nextBtn) {
        prevBtn.addEventListener('click', () => {
            plusSlides(-1);
            resetSlideTimer();
        });
        nextBtn.addEventListener('click', () => {
            plusSlides(1);
            resetSlideTimer();
        });
    }
}

function plusSlides(n) {
    showSlides(slideIndex += n);
}

function currentSlide(n) {
    showSlides(slideIndex = n);
    resetSlideTimer();
}

function showSlides(n) {
    let i;
    let slides = document.getElementsByClassName("slide");
    let dots = document.getElementsByClassName("dot");
    
    if (n > slides.length) {slideIndex = 1}    
    if (n < 1) {slideIndex = slides.length}
    
    for (i = 0; i < slides.length; i++) {
        slides[i].classList.remove("active");  
    }
    for (i = 0; i < dots.length; i++) {
        dots[i].classList.remove("active");
    }
    
    slides[slideIndex-1].classList.add("active");  
    dots[slideIndex-1].classList.add("active");
}

function startSlideTimer() {
    slideInterval = setInterval(function() {
        plusSlides(1);
    }, 5000); // Change image every 5 seconds
}

function resetSlideTimer() {
    clearInterval(slideInterval);
    startSlideTimer();
}

document.addEventListener('DOMContentLoaded', () => {
    initSlider();
});

