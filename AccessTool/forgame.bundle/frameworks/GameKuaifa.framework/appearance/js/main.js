/* *********
 *    author:Jason He
 *    version:1.0.0
 *    copyright:快发助手
 *    date:2015-05-06
 *    file:main.js
 ********* */

var KF = {};
(function (S) {
	var main = {
		init: function () {
			/* vertical center */
			main.verticalCenter($(".wrap"));
			$(window).resize(function(e) {
				main.verticalCenter($(".wrap"));
			});
			/* popup close */
			$(".popup-close").click(function(e) {
                window.location.href="jskit://www.kuaifa.com/close";
			});
            /* popup return */
            $(".popup-return").attr("href","jskit://www.kuaifa.com/return");
			/* send code */
			main.codeText();
			$(".code-btn").click(function(e) {
				main.codeSend();
			});
			/* pay radio */
			$("input[name='pay-radio']").click(function(e) {
				var flag = $(this).data("flag");
                                               alert(flag);
				if (flag == 0) {
					$(".pay-toggle").hide();
				} else if (flag == 1) {
					$(".pay-toggle").show();
				}
			});
		},
		verticalCenter: function (dom) {
			var domHeight = dom.height();
			var windowHeight = $(window).height();
			if (windowHeight >= domHeight + 90) {
				var domMarginTop = (windowHeight - domHeight) / 3;
				dom.css({"margin-top": domMarginTop, "margin-bottom": 0});
			} else {
				dom.css({"margin-top": "30px", "margin-bottom": "30px"});
			}
		},
		codeText: function () {
			var flag = $("#code-flag").val();
			if (flag == "countdown") {
				$(".code-btn").text("60秒后重新发送");
				main.countdown();
			} else if (flag == "send") {
				$(".code-btn").text("发送验证码");
			}
		},
		codeSend: function () {
			if ($(".code-btn").text() == "发送验证码") {
				$.ajax({
					type: "GET",
					url: $(".code-btn").data("api"),
                    dataType: "json", 
                    async: false,
					success: function (data) {
						if (data.result != 0) {
							//alert(data.errorInfo);
						} else {
							$(".code-btn").text("60秒后重新发送");
							main.countdown();
						}
					}
				});
			}
		},
		countdown: function () {
			var i = 59;
			var countdown = setInterval(function () {
				if (i > 0) {
					$(".code-btn").text(i + "秒后重新发送");
					i--;
				} else if (i == 0) {
					$(".code-btn").text("发送验证码");
					clearInterval(countdown);
				}
			}, 1000);
		}
	};
	$(document).ready(function(e) {
		main.init();
	});
	return S.main = main;
})(KF);