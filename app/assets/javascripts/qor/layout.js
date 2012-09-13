var qLayout = (function() {
  ////////////////////////////////////////////////////////////////////////////////
  // Drag Events
  ////////////////////////////////////////////////////////////////////////////////
  function handleDragStart(e) {
    e.dataTransfer.start_position = {x: e.pageX, y: e.pageY};
  }

  function handleDragOver(e) {
    if (e.preventDefault) { e.preventDefault(); }
    return false;
  }

  function handleDragEnter(e) {
    doHoverAction(e);
  }

  function handleDragLeave(e) {
    doNormalAction(e);
  }

  function handleDrop(e) {
    if (e.stopPropagation) { e.stopPropagation(); } // stops the browser from redirecting.
    return false;
  }

  function handleDragEnd(e) {
    var start_position = e.dataTransfer.start_position;
    this.style.left = parseInt(this.style.left) + (e.pageX - start_position.x) + 'px'
    this.style.top  = parseInt(this.style.top) + (e.pageY - start_position.y) + 'px';

    var setting_id = this.getAttribute('qor_layout_elements')
    var data = {setting : {style_attributes : {left: this.style.left, top: this.style.top}}}

    $.ajax({
      type: "PUT",
      url: "/qor/layout/settings/" + setting_id,
      data: data,
    });
  }

  ////////////////////////////////////////////////////////////////////////////////
  // Element Actions
  ////////////////////////////////////////////////////////////////////////////////
  function doAction(e, action) {
    var elem = (e instanceof HTMLElement) ? e : e.target;
    elem.setAttribute("data-qlayout-action", action);
  }

  function doHoverAction(e) {
    doAction(e, 'hover');
  }

  function doMoveAction(e) {
    doAction(e, 'move');
  }

  function doNormalAction(e) {
    doAction(e, 'normal');
  }
  ////////////////////////////////////////////////////////////////////////////////

  function registerAsDarggable(dom, root) {
    dom.setAttribute('draggable', true);

    dom.addEventListener('mouseover', doHoverAction, false);
    dom.addEventListener('mouseout', doNormalAction, false);

    dom.addEventListener('dragstart', handleDragStart, false);
    dom.addEventListener('dragenter', handleDragEnter, false);
    dom.addEventListener('dragover', handleDragOver, false);
    dom.addEventListener('dragleave', handleDragLeave, false);
    dom.addEventListener('drop', handleDrop, false);
    dom.addEventListener('dragend', handleDragEnd, false);

    var layout_parents = $(dom).parents('[qor_layout_elements]');
    var parent = layout_parents.length > 0 ? layout_parents[0] : root;

    var old_position    = dom.getBoundingClientRect();
    var parent_position = parent.getBoundingClientRect();
    dom.style.left      = (old_position.left - parent_position.left) + "px";
    dom.style.top       = (old_position.top - parent_position.top) + "px";
    dom.style.float     = 'none';
    dom.style.position  = 'absolute';

    dom.setAttribute("data-qlayout-element", true);
  }

  function init(root) {
    function refresh() {
      var children = root.querySelectorAll('[qor_layout_draggable_elements]');
      for (var i=0; i < children.length; i++) {
        registerAsDarggable(children[i], root);
      }
    }

    function add(elem) {
      registerAsDarggable(elem, root);
    }

    function html(value) {
      if (value) { root.innerHTML = value; refresh(); }
      return root.innerHTML;
    }

    refresh();

    return {
      add  : add,
      html : html
    }
  }

  return {
    init : init
  }
})();
