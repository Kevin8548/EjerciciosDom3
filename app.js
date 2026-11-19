const data = [
  { id: "p01", title: "Montaña", desc: "Rocas y niebla", src: "https://picsum.photos/id/1018/1200/675" },
  { id: "p02", title: "Amanecer", desc: "Luz suave y cielo polar", src: "https://picsum.photos/id/1015/1200/675" },
  { id: "p03", title: "Río", desc: "Paseo reflexivo por el río", src: "https://picsum.photos/id/1011/1200/675" },
  { id: "p04", title: "Alaska", desc: "Fauna salvaje de Alaska", src: "https://picsum.photos/id/1020/1200/675" },
  { id: "p05", title: "Desierto", desc: "Atardecer en el desierto", src: "https://picsum.photos/id/1016/1200/675" },
  { id: "p06", title: "Lago", desc: "Lago en perspectiva", src: "https://picsum.photos/id/1005/1200/675" }
];

// Selección de elementos del DOM
const thumbs = document.querySelector("#thumbs");
const heroImg = document.querySelector("#heroImg");
const heroTitle = document.querySelector("#heroTitle");
const heroDesc = document.querySelector("#heroDesc");
const likeBtn = document.querySelector("#likeBtn");
const counter = document.querySelector("#counter");

const prevBtn = document.querySelector("#prevBtn");
const nextBtn = document.querySelector("#nextBtn");
const playBtn = document.querySelector("#playBtn");

// Estado de la aplicación
let currentIndex = 0;
const likes = {};

let autoPlayId = null;
let isPlaying = false;
const AUTO_TIME = 3000; // milisegundos entre imágenes

// Renderizar miniaturas
function renderThumbs() {
  thumbs.innerHTML = data.map((item, index) => {
    return `
      <article class="thumb ${index === currentIndex ? "active" : ""}" data-index="${index}">
        <span class="badge">${index + 1}</span>
        <img src="${item.src}" alt="${item.title}">
      </article>
    `;
  }).join("");
}

// Actualizar el botón de reproducción
function updatePlayButton() {
  playBtn.textContent = isPlaying ? "⏸️" : "▶️";
  playBtn.dataset.state = isPlaying ? "stop" : "play";
}

function updateCounter() {
  counter.textContent = `${currentIndex + 1} / ${data.length}`;
}

// Cambio en la miniatura activa
function updateActiveThumb() {
  document.querySelectorAll(".thumb").forEach((thumb, i) => {
    thumb.classList.toggle("active", i === currentIndex);
  });
}

function updateLikeBtn() {
  const currentItem = data[currentIndex];
  const isLiked = likes[currentItem.id] === true;

  likeBtn.textContent = isLiked ? " ❤️ " : " 🤍 ";
  likeBtn.classList.toggle("on", isLiked);
  likeBtn.setAttribute("aria-pressed", isLiked);
}

// Renderizar imagen en el visor principal
function renderHero(index) {
  const item = data[index];

  heroImg.src = item.src;
  heroImg.alt = item.title;

  heroTitle.textContent = item.title;
  heroDesc.textContent = item.desc;

  updateCounter();
  updateActiveThumb();
  updateLikeBtn();
}

// Cambiar de imagen con transición
function changeSlide(newIndex) {
  heroImg.classList.add("fade-out");
  setTimeout(() => {
    currentIndex = newIndex;
    renderHero(currentIndex);
    heroImg.classList.remove("fade-out");
  }, 350);
}

function nextSlide() {
  const newIndex = (currentIndex + 1) % data.length;
  changeSlide(newIndex);
}

function prevSlide() {
  const newIndex = (currentIndex - 1 + data.length) % data.length;
  changeSlide(newIndex);
}

function startAutoPlay() {
  autoPlayId = setInterval(() => {
    nextSlide();
  }, AUTO_TIME);

  isPlaying = true;
  updatePlayButton();
}

function stopAutoPlay() {
  clearInterval(autoPlayId);
  autoPlayId = null;
  isPlaying = false;
  updatePlayButton();
}

function toggleAutoPlay() {
  if (isPlaying) {
    stopAutoPlay();
  } else {
    startAutoPlay();
  }
}

// Botón me gusta
likeBtn.addEventListener("click", () => {
  const currentItem = data[currentIndex];
  likes[currentItem.id] = !likes[currentItem.id];
  updateLikeBtn();
});

// Clic en las miniaturas
thumbs.addEventListener("click", (e) => {
  const thumb = e.target.closest(".thumb");
  if (!thumb) return;

  const newIndex = Number(thumb.dataset.index);
  if (newIndex === currentIndex) return;
  changeSlide(newIndex);
});

nextBtn.addEventListener("click", nextSlide);
prevBtn.addEventListener("click", prevSlide);
playBtn.addEventListener("click", toggleAutoPlay);

// Teclado
document.addEventListener("keydown", (e) => {
  if (e.key === "ArrowRight") {
    nextSlide();
  }
  if (e.key === "ArrowLeft") {
    prevSlide();
  }
});

renderThumbs();
renderHero(currentIndex);
updatePlayButton();