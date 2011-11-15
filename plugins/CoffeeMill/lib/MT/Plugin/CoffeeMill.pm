package MT::Plugin::CoffeeMill;
use strict;
use warnings;

sub transform_edit_template {
    my ( $cb, $app, $param ) = @_;
    my $coffee = sprintf '%splugins/CoffeeMill/coffee-script.js', MT->static_path;
    $param->{js_include} ||= '';
    $param->{js_include} .= qq{<script src="$coffee"></script>};
    $param->{jq_js_include} ||= '';
    $param->{jq_js_include} .= <<'JAVASCRIPT';
;(function ($) {
    var js;
    var init_coffee = function () {
        if ( $('#text').val().match(new RegExp('^<mt:ignore>Coffee__((?:.|\n)*)__eeffoC</mt:ignore>((?:.*|\n)*)')) ) {
            var coffee, outfile;
            coffee = RegExp.$1;
            js     = RegExp.$2;
            $('#text').val(coffee);
            editor.setCode(coffee);
            outfile = $('#outfile').val();
            $('#outfile').val( outfile.replace(/\.js$/i, '.coffee') );
        }
    };

    (function () {
        if ( editor && editor.editor )
            init_coffee();
        else
            setTimeout( arguments.callee, 501 );
    })();

    $('form#template-listing-form').submit( function () {
        if ( $('#outfile').val().match(/\.coffee$/) ) {
            var coffee, compiled;
            syncEditor();
            syncEditor = function () {};
            coffee = $('#text').val();
            try {
                compiled = CoffeeScript.compile(coffee);
            }
            catch (e) {
                alert('Compile error in coffee-script. Javascript would not to be updated.\n\n' + e);
            }
            if ( compiled ) {
                compiled = compiled.replace( /\/\*\s*?</g, '<' );
                compiled = compiled.replace( /\>\s*?\*\//g, '>' );
                js = compiled;
            }
            var text =
                '<mt:ignore>Coffee__'
              + coffee
              + '__eeffoC</mt:ignore>'
              + js
              ;
            $('#text').val(text);
            var outfile = $('#outfile').val();
            $('#outfile').val( outfile.replace(/\.coffee$/, '.js') );
        }
        return true;
    });
})(jQuery);
JAVASCRIPT
}

1;
