function KartRenderer(el, width, height) {
  var isInit = false;
  
  var mainRenderer, captureRender;
  var mainCamera, captureCamera;
  var kart;
  var discrete = true;
  var angle = 0;
  
  this.isInit = function() {
    return isInit;
  };
  
  var translateKart = function(kart, angle) {
    kart.translateZ(-1.5);
      
    kart.rotation.y -= angle / 100 * Math.PI / 2;
  };
  
  this.init = function(captureWidth, captureHeight, circuitIdx, newDiscrete) {
    if (isInit) return;
    isInit = true;
    discrete = newDiscrete;
    
    mainRenderer = new THREE.WebGLRenderer({
    });
    
    mainRenderer.setPixelRatio(window.devicePixelRatio);
    mainRenderer.setSize(width, height);
    el.appendChild(mainRenderer.domElement);
    
    captureRender = new THREE.WebGLRenderer({
      preserveDrawingBuffer: true
    });
    
    captureRender.setPixelRatio(1);
    captureRender.setSize(captureWidth, captureHeight);
    
    var scene = new THREE.Scene();
    scene.background = new THREE.Color(0xDDEEFF);
    
    var light = new THREE.AmbientLight(0xFFFFFF);
    scene.add(light);
    
    var circuits = new Circuits();
    var start = circuits.getStart(circuitIdx);
    
    kart = new THREE.Object3D();
    kart.position.x = start[0];
    kart.position.y = start[1];
    kart.position.z = start[2];
    kart.rotation.y = start[3] * Math.PI / 2;
    scene.add(kart);
    
    mainCamera = new THREE.PerspectiveCamera(90, width / height, 1, 10000);
    mainCamera.rotation.x = -0.5 * Math.PI / 2;
    kart.add(mainCamera);
    
    captureCamera = new THREE.PerspectiveCamera(90, captureWidth / captureHeight, 1, 10000);
    captureCamera.rotation.x = -0.5 * Math.PI / 2;
    kart.add(captureCamera);
    
    var audio = new Audio(circuits.getAudio(circuitIdx)); 
    if (audio) {
      audio.addEventListener('ended', function() {
        this.currentTime = 0;
        this.play();
      }, false);
      audio.play();
    }
    
    var image = new Image();
    image.src = circuits.getCircuit(circuitIdx);
    
    var texture = new THREE.Texture();
    texture.image = image;
    image.onload = function() {
      texture.needsUpdate = true;
    };
    
    texture.repeat.set(3, 3);
    texture.wrapS = texture.wrapT = THREE.MirroredRepeatWrapping;
    
    var floor = new THREE.Mesh(
      new THREE.BoxGeometry(1000, 1, 1000),
      new THREE.MeshLambertMaterial( { color: 0xFFFFFF, map: texture } )
    );
    floor.position.x = 0;
    floor.position.y = 0;
    floor.position.z = 0;
    scene.add(floor);
    
    setInterval(function() {
      translateKart(kart, angle);
    }, 100);
    
    document.onkeydown = function (e) {
      switch(e.keyCode) {
        case 37: // left
          delta = discrete ? -1.5 : -0.5;
          break;
        case 39: // right
          delta = discrete ? 1.5 : 0.5;
          break;
      }
      
      angle = false ? delta : angle + delta;
      angle = Math.max(Math.min(9, angle), -9);
    };
    
    document.onkeyup = function (e) {
      if (discrete) angle = 0;
    };
    
    if (typeof(Shiny) !== "undefined") {
      Shiny.addCustomMessageHandler("kartsim_control", function(data) {
          angle = data.angle;
        }
      );
    }
    
    var animate = function() {
      requestAnimationFrame(animate);
      
      mainRenderer.render(scene, mainCamera);
      captureRender.render(scene, captureCamera);
      
      if (typeof(Shiny) !== "undefined") {
        var data = captureRender.domElement.toDataURL("image/png");
        Shiny.onInputChange("kartsim_capture", {
          data: data,
          angle: angle
        });
      }
    };
    
    animate();
  };
  
  this.resize = function(width, height) {
    if(!isInit) return;
    
    mainCamera.aspect = width / height;
    
    mainCamera.updateProjectionMatrix();
    captureCamera.updateProjectionMatrix();
    
    mainRenderer.setSize(width, height);
  };
}