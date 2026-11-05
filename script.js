
document.addEventListener('DOMContentLoaded',()=>{
 const toggle=document.querySelector('.menu-toggle'),nav=document.querySelector('.nav');
 if(toggle&&nav) toggle.addEventListener('click',()=>{nav.classList.toggle('open');toggle.setAttribute('aria-expanded',nav.classList.contains('open')?'true':'false')});
 const here=location.pathname.split('/').pop()||'index.html';
 document.querySelectorAll('.nav a').forEach(a=>{if(a.getAttribute('href')===here)a.classList.add('active')});
});
