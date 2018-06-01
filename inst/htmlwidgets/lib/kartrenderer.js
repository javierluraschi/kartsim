function KartRenderer(el, width, height) {
  var isInit = false;
  
  var mainRenderer, captureRender;
  var mainCamera, captureCamera;
  var kart;
  var discrete = true;
  var angle = 0;

  var audio = null;
  var audioPlaying = false;
  var audioDiv = null;
  
  this.isInit = function() {
    return isInit;
  };
  
  var translateKart = function(kart, angle) {
    kart.translateZ(-1.5);
      
    kart.rotation.y -= angle / 100 * Math.PI / 2;
  };

  var play = function() {
    if (!audioPlaying) {
      audioPlaying = true;

      if (audio) {
        audio.addEventListener('ended', function() {
          audio.currentTime = 0;
          if (audioPlaying) audio.play();
        }, false);

        audio.play();
      }
    } else {
      audioPlaying = false;
      audio.pause();
    }

    audioDiv.style.opacity = audioPlaying ? "0.8" : "0.4";
  }
  
  this.init = function(captureWidth, captureHeight, circuitIdx, newDiscrete) {
    if (isInit) return;
    isInit = true;
    discrete = newDiscrete;
    var circuits = new Circuits();

    audio = new Audio(circuits.getAudio(circuitIdx)); 
    audioDiv = document.createElement("div");
    audioDiv.onclick = play;
    audioDiv.style.position = "absolute";
    audioDiv.style.width = "30px";
    audioDiv.style.height = "30px";
    audioDiv.style.backgroundSize = "100%";
    audioDiv.style.backgroundImage = "url('data:image/svg+xml;base64,PHN2ZyBoZWlnaHQ9JzIwMCcgd2lkdGg9JzIwMCcgIGZpbGw9IiMwMDAwMDAiIHhtbG5zOnJkZj0iaHR0cDovL3d3dy53My5vcmcvMTk5OS8wMi8yMi1yZGYtc3ludGF4LW5zIyIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczpjYz0iaHR0cDovL2NyZWF0aXZlY29tbW9ucy5vcmcvbnMjIiB4bWxuczpkYz0iaHR0cDovL3B1cmwub3JnL2RjL2VsZW1lbnRzLzEuMS8iIHZlcnNpb249IjEuMSIgeD0iMHB4IiB5PSIwcHgiIHZpZXdCb3g9IjAgMCAxNiAxNiI+PGcgdHJhbnNmb3JtPSJ0cmFuc2xhdGUoMCAtMTAzNi40KSI+PHBhdGggZD0ibTEgMTA0Mi40djRoM2wzIDNoMXYtMTBoLTFsLTMgM3oiPjwvcGF0aD48cGF0aCBkPSJtMTMuMjUgMTAzOS40LTAuNzgxMjUgMC42MjVjMC45NjUxOSAxLjE5OTggMS41MzEyIDIuNzE1MyAxLjUzMTIgNC4zNzVzLTAuNTY2MDYgMy4xNzUyLTEuNTMxMiA0LjM3NWwwLjc4MTI1IDAuNjI1YzEuMDk4My0xLjM2OTcgMS43NS0zLjEwNzggMS43NS01cy0wLjY1MTc0LTMuNjMwMy0xLjc1LTV6bS0xLjU2MjUgMS4yNS0wLjgxMjUgMC42NTYzYzAuNjg3OTEgMC44NTY1IDEuMTI1IDEuOTA5NiAxLjEyNSAzLjA5MzdzLTAuNDM3MDkgMi4yMzcyLTEuMTI1IDMuMDkzOGwwLjgxMjUgMC42NTYyYzAuODIzMTItMS4wMjcxIDEuMzEyNS0yLjMzMTQgMS4zMTI1LTMuNzVzLTAuNDg5MzgtMi43MjI5LTEuMzEyNS0zLjc1em0tMS41NjI1IDEuMjUtMC43ODEyNSAwLjYyNWMwLjQxMTI3IDAuNTEzNSAwLjY1NjI1IDEuMTY1OSAwLjY1NjI1IDEuODc1cy0wLjI0NDk4IDEuMzYxNS0wLjY1NjI1IDEuODc1bDAuNzgxMjUgMC42MjVjMC41NDUzMi0wLjY4MzYgMC44NzUtMS41NTc2IDAuODc1LTIuNXMtMC4zMjk2OC0xLjgxNjQtMC44NzUtMi41eiI+PC9wYXRoPjwvZz48L3N2Zz4=')";
    audioDiv.style.marginLeft = "10px";
    audioDiv.style.marginTop = "10px";
    audioDiv.style.opacity = "0.4";

    el.appendChild(audioDiv);
    
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
          delta = discrete ? -5 : -0.5;
          break;
        case 39: // right
          delta = discrete ? 5 : 0.5;
          break;
      }
      
      angle = discrete ? delta : angle + delta;
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