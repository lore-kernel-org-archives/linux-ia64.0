From: Arun Sharma <arun.sharma@intel.com>
Date: Tue, 24 Jun 2003 22:16:40 +0000
Subject: IA-32 support patch: munmap should return EINVAL if size == 0
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------090406080403070706090505"
Message-Id: <marc-linux-ia64-105649312310734@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------090406080403070706090505
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit


Native IA-32 returns EINVAL on a unmap of size 0. Our behavior is currently not compatible.

Please apply to both 2.4 and 2.5.

	-Arun

--------------090406080403070706090505
Content-Type: text/plain;
 name="munmap.21.txt"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="munmap.21.txt"

LS0tIGxpbnV4LTIuNC9hcmNoL2lhNjQvaWEzMi9zeXNfaWEzMi5jCVR1ZSBNYXkgMjcgMTA6
MjA6MTAgMjAwMw0KKysrIGxpbnV4LWNoYW5nZS9hcmNoL2lhNjQvaWEzMi9zeXNfaWEzMi5j
CVRodSBNYXkgMjkgMDA6NTA6MzMgMjAwMw0KQEAgLTU0Nyw3ICs1NDcsNyBAQA0KICNpZiBQ
QUdFX1NISUZUIDw9IElBMzJfUEFHRV9TSElGVA0KIAlyZXQgPSBzeXNfbXVubWFwKHN0YXJ0
LCBlbmQgLSBzdGFydCk7DQogI2Vsc2UNCi0JaWYgKHN0YXJ0ID4gZW5kKQ0KKwlpZiAoc3Rh
cnQgPj0gZW5kKQ0KIAkJcmV0dXJuIC1FSU5WQUw7DQogDQogCXN0YXJ0ID0gUEFHRV9BTElH
TihzdGFydCk7DQoNCg0K
--------------090406080403070706090505--

