From: Arun Sharma <arun.sharma@intel.com>
Date: Mon, 11 Oct 2004 19:27:49 +0000
Subject: [PATCH] Kill warnings in sys_ia32.c
Message-Id: <416ADEB5.8040803@intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------040501030608090904030309"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------040501030608090904030309
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi Tony,

The recent patch on waitid support seems to have introduced some warnings. This patch adds missing prototypes to fix the warnings. Please apply.

	-Arun


--------------040501030608090904030309
Content-Type: text/plain;
 name="ia32-missing-proto.patch"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="ia32-missing-proto.patch"

CkFkZCBtaXNzaW5nIHByb3RvdHlwZXMgdG8ga2lsbCB3YXJuaW5ncyBpbiBzeXNfaWEzMi5j
CgpTaWduZWQtb2ZmLWJ5OiBBcnVuIFNoYXJtYSA8YXJ1bi5zaGFybWFAaW50ZWwuY29tPgoK
LS0tIGxpbnV4LTIuNi1jdnMvYXJjaC9pYTY0L2lhMzIvaWEzMnByaXYuaAk4IE9jdCAyMDA0
IDAyOjU3OjI4IC0wMDAwCTEuMTIKKysrIGxpbnV4LTIuNi1jdnMvYXJjaC9pYTY0L2lhMzIv
aWEzMnByaXYuaAkxMSBPY3QgMjAwNCAxOToxNzozMSAtMDAwMApAQCAtNTU5LDYgKzU1OSwx
MCBAQAogZXh0ZXJuIGludCBzYXZlX2lhMzJfZnBzdGF0ZSAoc3RydWN0IHRhc2tfc3RydWN0
ICosIHN0cnVjdCBpYTMyX3VzZXJfaTM4N19zdHJ1Y3QgX191c2VyICopOwogZXh0ZXJuIGlu
dCBzYXZlX2lhMzJfZnB4c3RhdGUgKHN0cnVjdCB0YXNrX3N0cnVjdCAqLCBzdHJ1Y3QgaWEz
Ml91c2VyX2Z4c3Jfc3RydWN0IF9fdXNlciAqKTsKIAorLyogUHJvdG90eXBlcyBmb3IgdXNl
IGluIHN5c19pYTMyLmMgKi8KK2ludCBjb3B5X3NpZ2luZm9fdG9fdXNlcjMyIChzaWdpbmZv
X3QzMiBfX3VzZXIgKnRvLCBzaWdpbmZvX3QgKmZyb20pOworaW50IGNvcHlfc2lnaW5mb19m
cm9tX3VzZXIzMiAoc2lnaW5mb190ICp0bywgc2lnaW5mb190MzIgX191c2VyICpmcm9tKTsK
KwogI2VuZGlmIC8qICFDT05GSUdfSUEzMl9TVVBQT1JUICovCiAKICNlbmRpZiAvKiBfQVNN
X0lBNjRfSUEzMl9QUklWX0ggKi8K
--------------040501030608090904030309--
