module ApplicationHelper
  def title(text)
    content_for :title do
      text
    end
  end

  def google_analytics(app_id)
    if Rails.env.production?
      javascript_tag <<-END
        var _gaq = _gaq || [];
        _gaq.push(['_setAccount', #{app_id}]);
        _gaq.push(['_trackPageview']);

        (function() {
          var ga = document.createElement('script');
          ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
          ga.setAttribute('async', 'true');
          document.documentElement.firstChild.appendChild(ga);
        })();
      END
    end
  end
end
