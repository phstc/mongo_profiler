$(function(){
    $('.toggle_profile').click(function(){
      var $this = $(this);
      var $pre = $this.parents('tr').find('pre');

      var height = '400px';

      if($pre.height() > 300){
        height = '60px';
        // $this.text('+');
      } else {
        // $this.text('-');
      }

      $pre.animate({ 'height': height, 'max-height': height });

      return false;
    });
});
