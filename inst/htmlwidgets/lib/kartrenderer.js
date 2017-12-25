function KartRenderer(el, width, height) {
  var isInit = false;
  
  var mainRenderer;
  var camera;
  
  this.isInit = function() {
    return isInit;
  };
  
  this.init = function(captureWidth, captureHeight, circuitIdx) {
    if (isInit) return;
    isInit = true;
    
    mainRenderer = new THREE.WebGLRenderer({
    });
    
    mainRenderer.setPixelRatio(window.devicePixelRatio);
    mainRenderer.setSize(width, height);
    el.appendChild(mainRenderer.domElement);
    
    var captureRender = new THREE.WebGLRenderer({
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
    
    var kart = new THREE.Object3D();
    kart.position.x = start[0];
    kart.position.y = start[1];
    kart.position.z = start[2];
    kart.rotation.y = -Math.PI / 2;
    scene.add(kart);
    
    camera = new THREE.PerspectiveCamera(70, width / height, 1, 10000);
    camera.rotation.y += start[3] * Math.PI / 2;
    kart.add(camera);
    
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
    
    var direction = "forward";
    setInterval(function() {
      camera.translateZ(-2);
      if (direction == "left") camera.rotation.y -= -0.05 * Math.PI / 2;
      if (direction == "right") camera.rotation.y -= 0.05 * Math.PI / 2;
    }, 100);
    
    document.onkeydown = function (e) {
      switch(e.keyCode) {
        case 37:
          direction = "left";
          break;
          case 39:
            direction = "right";
            break;
            default:
              direction = "forward";
      }
    };
    
    document.onkeyup = function (e) {
      direction = "forward";
    };
    
    if (typeof(Shiny) !== "undefined") {
      Shiny.addCustomMessageHandler("hexkart_control", function(data) {
          direction = data.direction;
        }
      );
    }
    
    var animate = function() {
      requestAnimationFrame(animate);
      
      mainRenderer.render(scene, camera);
      captureRender.render(scene, camera);
      
      if (typeof(Shiny) !== "undefined") {
        var data = captureRender.domElement.toDataURL("image/png");
        Shiny.onInputChange("hexkart_capture", {
          data: data,
          direction: direction
        });
      }
    };
    
    animate();
  };
  
  this.resize = function(width, height) {
    if(!isInit) return;
    
    camera.aspect = width / height;
    camera.updateProjectionMatrix();
    mainRenderer.setSize(width, height);
  };
}