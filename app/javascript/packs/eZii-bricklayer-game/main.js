import * as THREE from 'three';
import { Interaction } from 'three.interaction';

import { OrbitControls } from '../kmz/jsm/controls/OrbitControls.js';
import GltfLoadAnimatedObject from '../eZii-bricklayer-game/gltf-load-animated-object.js';

export default class EZIIBrickLayerGameMain {
	constructor() {
		this.mixers = {};
		this.stoppedMixers = {};
		this.scene = undefined;
		this.cubes = [];
		this.docking = undefined;
		this.camera = undefined;
		this.renderer = undefined;
		this.controls = undefined;
		this.clock = new THREE.Clock();
		
	    this.rayCaster = new THREE.Raycaster();
	    this.mousePosition = new THREE.Vector2();
		
	}
	
	
	every10MilliSeconds(callback) {
		setInterval(callback, 10);
	}
	
	
	findDomDockingPoint() {
		var promise = new Promise((resolve, reject) => {
			var notFound = true;
			var i = 0;
			while(notFound) {
				this.docking = document.body.querySelector('#docking-point-for-threejs');
				if(!this.docking) {
					i++;
					if (i < 40) { continue } else { reject("couldn't find element with id docking-point-for-threejs") };
				} else {
					
					resolve();
					notFound = false;
				}
			}		
		});
		
		return promise;
	}
	
	
	init() {

        this.scene = new THREE.Scene();

	
		var geometry = new THREE.BoxGeometry( 100, 100, 10 );
		var material = new THREE.MeshBasicMaterial( {color: 0x00ff00} );
	
		// §
		this.cubes.push(new THREE.Mesh( geometry, material ));
        this.scene.add( this.cubes[0] );
        
        this.cubes[0].position.z = -30;
	
		var geometry2 = new THREE.BoxGeometry( 100, 100, 10 );
		var material2 = new THREE.MeshBasicMaterial( {color: 0x0000ff} );
	
		// §
		this.cubes.push(new THREE.Mesh( geometry2, material2 ));
		this.scene.add(	 this.cubes[1] );
    
        
        this.cubes[1].position.z = 30;
        
		this.scene.background = new THREE.Color( 0x999999 );
		var light = new THREE.DirectionalLight( 0xffffff );
		light.position.set( 0.5, 1.0, 0.5 ).normalize();
		this.scene.add( light );
		this.camera = new THREE.PerspectiveCamera( 35, this.docking.clientWidth / this.docking.clientHeight, 1, 500 );
		this.camera.position.y = 5;
		this.camera.position.z = 10;
		this.scene.add( this.camera );
		this.grid = new THREE.GridHelper( 1000, 1000, 0xffffff, 0x555555 );
		this.scene.add( this.grid );
		this.renderer = new THREE.WebGLRenderer( { antialias: true } );
		this.renderer.setPixelRatio( window.devicePixelRatio );
		this.renderer.setSize( this.docking.clientWidth, this.docking.clientHeight );
		this.canvas = this.renderer.domElement;
		
		this.docking.appendChild( this.canvas );
		
		this.canvasPosition = $(this.canvas).position(); 
	
	
		this.interaction = new Interaction(this.renderer, this.scene, this.camera);
	
	    this.controls = new OrbitControls( this.camera, this.renderer.domElement );
		// controls.addEventListener( 'change', render );
		this.controls.update();
		window.addEventListener( 'resize', this.onWindowResize, false );
	}
	




	onWindowResize() {
		this.camera.aspect = this.docking.clientWidth / this.docking.clientHeight;
		this.camera.updateProjectionMatrix();
		this.renderer.setSize( this.docking.clientWidth, this.docking.clientHeight );
		this.render();
	}
	
	
	
	render() {
		this.renderer.render( this.scene, this.camera );
	}
	
	


	moveObjectZAxis(object) {
		object.position.z += 10;
	}
	
	


	async addObject(id) {	
		var loadObject = new GltfLoadAnimatedObject(this.scene)
		
		let promise = new Promise(async function(resolve, reject) {
			let [object, mixer] = await loadObject.addObject(id);
			resolve([object, mixer, id])

		});
		
		return promise;
	}
	
	
	
	animate(id) {
		// debugger;
				requestAnimationFrame( () => { this.animate.bind(this)(id) } );
				if ( this.mixers[id] ) this.mixers[id].update( this.clock.getDelta() );
				this.controls.update();
				this.render();
	}
	
	stopAnimation(id) {
		this.stoppedMixers[id] = this.mixers[id];
		
		delete this.mixers[id];
	}
	
	startAnimation(id) {
		if(this.mixers[id] !== undefined) return;
		this.mixers[id] = this.stoppedMixers[id];
		
		delete this.stoppedMixers[id];
	}
	
	
	tiltCurrentlySelectedObjectUpwards() {
		if(window.currentlySelectedObject !== undefined) {
			window.currentlySelectedObject.tiltUpwards();

		} else {
			console.warn("currentlySelectedObject is undefined");
		}
	}
	
	tiltCurrentlySelectedObjectDownwards() {
		if(window.currentlySelectedObject !== undefined) {
			window.currentlySelectedObject.tiltDownwards();
			
		} else {
			console.warn("currentlySelectedObject is undefined");
		}
	}
	
	//
	// getClicked3DPoint(evt) {
	//     evt.preventDefault();
	//
	//     this.mousePosition.x = ((evt.clientX - this.canvasPosition.left) / this.docking.width) * 2 - 1;
	//     this.mousePosition.y = -((evt.clientY - this.canvasPosition.top) / this.docking.height) * 2 + 1;
	//
	//     this.rayCaster.setFromCamera(this.mousePosition, this.camera);
	// 	debugger;
	//     var intersects = this.rayCaster.intersectObjects(this.cubes, true);
	//
	//     if (intersects.length > 0)
	//         return intersects[0].point;
	// };
	
}