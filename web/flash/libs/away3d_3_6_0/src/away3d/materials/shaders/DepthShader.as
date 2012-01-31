﻿package away3d.materials.shaders{	import away3d.cameras.lenses.AbstractLens;
	import away3d.arcane;	import away3d.containers.*;	import away3d.core.base.*;	import away3d.core.render.*;	import away3d.core.utils.*;		import flash.display.*;	import flash.filters.ColorMatrixFilter;	import flash.geom.*;		use namespace arcane;		/**	 * Shader class for environment lighting.	 */    public class DepthShader extends AbstractShader    {    	/** @private */        arcane override function updateMaterial(source:Object3D, view:View3D):void        {        	if (_filterDirty)        		updateFilter();        	        	if (_materialDirty || view._updatedObjects[source] || view.updated)        		updateFaces(source, view);        }        		/** @private */        arcane override function renderLayer(priIndex:uint, viewSourceObject:ViewSourceObject, renderer:Renderer, layer:Sprite, level:int):int        {        	super.renderLayer(priIndex, viewSourceObject, renderer, layer, level);			    		_shape = _source.session.getShape(this, level++, layer);        	_shape.filters = [_colorFilter];    					_source.session.renderTriangleBitmap(_bitmap, getUVData(priIndex), _screenVertices, _screenIndices, _startIndex, _endIndex, smooth, false, _shape.graphics);						if (debug)                _source.session.renderTriangleLine(0, 0x0000FF, 1, _screenVertices, renderer.primitiveCommands[priIndex], _screenIndices, _startIndex, _endIndex);                        return level;        }        		private var _bitmap:BitmapData;		private var _filterDirty:Boolean;		private var _colorFilter:ColorMatrixFilter = new ColorMatrixFilter();        private var _matrix:Matrix = new Matrix();        		private var _minZ:Number;		private var _maxZ:Number;        private var _shaderColor:uint;        private var _red:uint;        private var _green:uint;        private var _blue:uint;                protected function updateFilter():void        {        	_filterDirty = false;            	        _colorFilter.matrix = [0, 0, 0, 0, _red, 0, 0, 0, 0, _green, 0, 0, 0, 0, _blue, 1, 0, 0, 0, 0];	        	        invalidateFaces();        }				protected override function calcUVT(priIndex:uint, uvt:Vector.<Number>):Vector.<Number>		{			priIndex; uvt;						var lens:AbstractLens = _view.camera.lens;						uvt[uint(0)] = (lens.getScreenZ(_screenUVTs[uint(_screenIndices[_startIndex]*3 + 2)]) - _minZ)/(_maxZ - _minZ);    		uvt[uint(1)] = 1;    		uvt[uint(3)] = (lens.getScreenZ(_screenUVTs[uint(_screenIndices[_startIndex + 1]*3 + 2)]) - _minZ)/(_maxZ - _minZ);    		uvt[uint(4)] = 0.5;    		uvt[uint(6)] = (lens.getScreenZ(_screenUVTs[uint(_screenIndices[_startIndex + 2]*3 + 2)]) - _minZ)/(_maxZ - _minZ);    		uvt[uint(7)] = 0;    		    		return uvt;		}				protected override function calcMapping(priIndex:uint, map:Matrix):Matrix		{			priIndex;						var lens:AbstractLens = _view.camera.lens;
			eTri0x = (lens.getScreenZ(_screenUVTs[uint(_screenIndices[_startIndex]*3 + 2)]) - _minZ)*255/(_maxZ - _minZ);						//calulate mapping			map.a = (lens.getScreenZ(_screenUVTs[uint(_screenIndices[_startIndex + 1]*3 + 2)]) - _minZ)*255/(_maxZ - _minZ) - eTri0x;			map.b = 2;			map.c = (lens.getScreenZ(_screenUVTs[uint(_screenIndices[_startIndex + 2]*3 + 2)]) - _minZ)*255/(_maxZ - _minZ) - eTri0x;			map.d = 1;			map.tx = eTri0x;			map.ty = 0;            map.invert();                        return map;		}				/**		 * @inheritDoc		 */		protected function updateFaces(source:Object3D, view:View3D):void        {        	notifyMaterialUpdate();        	        	for each (var faceMaterialVO:FaceMaterialVO in _faceDictionary) {        		if (source == faceMaterialVO.source && view == faceMaterialVO.view) {	        		if (!faceMaterialVO.cleared)	        			faceMaterialVO.clear();	        		faceMaterialVO.invalidated = true;	        	}        	}        }				/**		 * @inheritDoc		 */        public function invalidateFaces(source:Object3D = null, view:View3D = null):void        {        	source; view;        	        	_materialDirty = true;        	        	for each (var _faceMaterialVO:FaceMaterialVO in _faceDictionary)        		_faceMaterialVO.invalidated = true;        }        		/**		 * @inheritDoc		 */        protected override function renderShader(priIndex:uint):void        {			//store a clone			if (_faceMaterialVO.cleared && !_parentFaceMaterialVO.updated) {				_faceMaterialVO.bitmap = _parentFaceMaterialVO.bitmap.clone();				_faceMaterialVO.bitmap.lock();			}						_faceMaterialVO.cleared = false;			_faceMaterialVO.updated = true;						_mapping = getMapping(priIndex);			            _mapping.concat(_faceMaterialVO.invtexturemapping);            			//draw into faceBitmap			_faceMaterialVO.bitmap.draw(_bitmap, _mapping, null, blendMode, _faceMaterialVO.bitmap.rect, smooth);        }						/**		 * Coefficient for the minimum Z of the depth map.		 */        public function get minZ():Number        {        	return _minZ;        }                public function set minZ(val:Number):void        {            _minZ = val;        }						/**		 * Coefficient for the maximum Z of the depth map.		 */        public function get maxZ():Number        {        	return _maxZ;        }                public function set maxZ(val:Number):void        {            _maxZ = val;        }						/**		 * Coefficient for the color shading at maxZ.		 */        public override function get color():uint        {        	return _shaderColor;        }                public override function set color(val:uint):void        {        	if (_shaderColor == val && !isNaN(_shaderColor))        		return;        	            _shaderColor = val;            _red = (_shaderColor & 0xFF0000) >> 16;            _green = (_shaderColor & 0x00FF00) >> 8;            _blue = _shaderColor & 0x0000FF;                        _filterDirty = true;        }        		/**		 * Creates a new <code>DepthShader</code> object.		 * 		 * @param	init	[optional]	An initialisation object for specifying default instance properties.		 */        public function DepthShader(init:Object = null)        {        	super(init);                        _minZ = ini.getNumber("minZ", 500);            _maxZ = ini.getNumber("maxZ", 2000);            color = ini.getNumber("color", 0x000000);                        _bitmap = new BitmapData(256, 2, false, 0);            _matrix.createGradientBox(256, 2, 0, 0, 0);                        var _shape:Shape = new Shape();    		var colArray:Array = [];    		var alphaArray:Array = [];    		var pointArray:Array = [];    		var i:int = 15;    		var c:int;    		    		while (i--) {    			c = 0xFF*(1 - i/14);    			colArray.push((c << 16) | (c << 8) | c);    			alphaArray.push(1);    			pointArray.push(c);    		}    		    		_shape.graphics.beginGradientFill(GradientType.LINEAR, colArray, alphaArray, pointArray, _matrix);    		_shape.graphics.drawRect(0, 0, 256, 2);    		_bitmap.fillRect(_bitmap.rect, 0);    		_bitmap.draw(_shape);        }            }}