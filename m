From: "Luming Yu" <luming.yu@gmail.com>
Date: Sat, 29 Sep 2007 07:53:43 +0000
Subject: [RFC patch] use thread.on_ustack to determine if on user stack
Message-Id: <3877989d0709290053s7b4e80b6t9e7127b9ccac522b@mail.gmail.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----=_Part_2906_21932210.1191052423900"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

------=_Part_2906_21932210.1191052423900
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hello list,

The PSR.lp bit of kernel thread kondemand sometimes would be set, then
causes set_pstate PAL call fails with invalid argument. I tracked down
to the place that the PSR.lp was set in do_notify_resume_user. I don't
understand why not use task->thread.on_ustack to
check if on user stack.in the first place. For optimization?

Signed-off-by: Yu Luming <luming.yu@intel.com>


  ptrace.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

------=_Part_2906_21932210.1191052423900
Content-Type: text/x-patch; name="user_stack.patch"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="user_stack.patch";
 filename="user_stack.patch"
X-Attachment-Id: f_f75tqsd4

LS0tIGxpbnV4LTIuNi4xOC5pYTY0L2luY2x1ZGUvYXNtLWlhNjQvcHRyYWNlLmguMAkyMDA3LTA5
LTI4IDIxOjQxOjE5LjAwMDAwMDAwMCArMDgwMAorKysgbGludXgtMi42LjE4LmlhNjQvaW5jbHVk
ZS9hc20taWE2NC9wdHJhY2UuaAkyMDA3LTA5LTI4IDIxOjQxOjQwLjAwMDAwMDAwMCArMDgwMApA
QCAtMjU3LDcgKzI1Nyw3IEBACiAjIGRlZmluZSB0YXNrX3B0X3JlZ3ModCkJCSgoKHN0cnVjdCBw
dF9yZWdzICopICgoY2hhciAqKSAodCkgKyBJQTY0X1NUS19PRkZTRVQpKSAtIDEpCiAjIGRlZmlu
ZSBpYTY0X3BzcihyZWdzKQkJCSgoc3RydWN0IGlhNjRfcHNyICopICYocmVncyktPmNyX2lwc3Ip
CiAjIGRlZmluZSB1c2VyX21vZGUocmVncykJCSgoKHN0cnVjdCBpYTY0X3BzciAqKSAmKHJlZ3Mp
LT5jcl9pcHNyKS0+Y3BsICE9IDApCi0jIGRlZmluZSB1c2VyX3N0YWNrKHRhc2sscmVncykJKChs
b25nKSByZWdzIC0gKGxvbmcpIHRhc2sgPT0gSUE2NF9TVEtfT0ZGU0VUIC0gc2l6ZW9mKCpyZWdz
KSkKKyMgZGVmaW5lIHVzZXJfc3RhY2sodGFzayxyZWdzKSAgKHRhc2stPnRocmVhZC5vbl91c3Rh
Y2spCiAjIGRlZmluZSBmc3lzX21vZGUodGFzayxyZWdzKQkJCQkJXAogICAoewkJCQkJCQkJXAog
CSAgc3RydWN0IHRhc2tfc3RydWN0ICpfdGFzayA9ICh0YXNrKTsJCQlcCg==
------=_Part_2906_21932210.1191052423900--
