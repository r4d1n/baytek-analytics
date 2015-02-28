//TEMPLATE LOADER
(function($){
    $(document).ready(function(){
        $.tpl = {};

        $("script.template").each(function(){
            $.tpl[$(this).attr("id")] = _.template($(this).html());

            $(this).remove();
        });
    });
})(jQuery);