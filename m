From: Arun Sharma <arun.sharma@intel.com>
Date: Fri, 12 Sep 2003 19:07:24 +0000
Subject: CONFIG_IA32_SUPPORT=m doesn't work
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------030500050505080904000706"
Message-Id: <marc-linux-ia64-106339410114264@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------030500050505080904000706
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit


The attached patch makes it static only for 2.4. This also makes it compatible with 2.6.

	-Arun


--------------030500050505080904000706
Content-Type: text/plain;
 name="ia32-config.patch"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="ia32-config.patch"

PT09PT0gYXJjaC9pYTY0L2NvbmZpZy5pbiAxLjI3IHZzIGVkaXRlZCA9PT09PQotLS0gMS4y
Ny9hcmNoL2lhNjQvY29uZmlnLmluCVR1ZSBTZXAgIDIgMTg6MDU6MDIgMjAwMworKysgZWRp
dGVkL2FyY2gvaWE2NC9jb25maWcuaW4JRnJpIFNlcCAxMiAxMjowMjozMyAyMDAzCkBAIC0x
MTIsNyArMTEyLDcgQEAKIAogYm9vbCAnVXNlIFBBTF9IQUxUX0xJR0hUIGluIGlkbGUgbG9v
cCcgQ09ORklHX0lBNjRfUEFMX0lETEUKIGJvb2wgJ1NNUCBzdXBwb3J0JyBDT05GSUdfU01Q
Ci10cmlzdGF0ZSAnU3VwcG9ydCBydW5uaW5nIG9mIExpbnV4L3g4NiBiaW5hcmllcycgQ09O
RklHX0lBMzJfU1VQUE9SVAorYm9vbCAnU3VwcG9ydCBydW5uaW5nIG9mIExpbnV4L3g4NiBi
aW5hcmllcycgQ09ORklHX0lBMzJfU1VQUE9SVAogYm9vbCAnUGVyZm9ybWFuY2UgbW9uaXRv
ciBzdXBwb3J0JyBDT05GSUdfUEVSRk1PTgogdHJpc3RhdGUgJy9wcm9jL3BhbCBzdXBwb3J0
JyBDT05GSUdfSUE2NF9QQUxJTkZPCiB0cmlzdGF0ZSAnL3Byb2MvZWZpL3ZhcnMgc3VwcG9y
dCcgQ09ORklHX0VGSV9WQVJTCg==
--------------030500050505080904000706--

