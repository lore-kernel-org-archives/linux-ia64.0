From: "Elliott, Robert (Servers)" <elliott@hpe.com>
Date: Fri, 02 Apr 2021 14:40:39 +0000
Subject: RE: [PATCH v2 3/3] hpsa: add an assert to prevent from __packed reintroduction
Message-Id: <TU4PR8401MB1055C76F16F4D8A2DCF541F8AB7A9@TU4PR8401MB1055.NAMPRD84.PROD.OUTLOOK.COM>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq1wntpgxxr.fsf@ca-mkp.ca.oracle.com>
 <20210330071958.3788214-1-slyfox@gentoo.org>
 <20210330071958.3788214-3-slyfox@gentoo.org>
 <CAK8P3a2CmQpKynwGbtdWH+1L4=SkX2y4XKggT=8DrnsjxU4hSw@mail.gmail.com>
In-Reply-To: <CAK8P3a2CmQpKynwGbtdWH+1L4=SkX2y4XKggT=8DrnsjxU4hSw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@kernel.org>, Sergei Trofimovich <slyfox@gentoo.org>
Cc: "Martin K. Petersen" <martin.petersen@oracle.com>, John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, Don Brace - C33706 <don.brace@microchip.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "storagedev@microchip.com" <storagedev@microchip.com>, linux-scsi <linux-scsi@vger.kernel.org>, "jszczype@redhat.com" <jszczype@redhat.com>, Scott Benesh <scott.benesh@microchip.com>, Scott Teel <scott.teel@microchip.com>, "thenzl@redhat.com" <thenzl@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

SXQgbG9va3MgbGlrZSBpYTY0IGltcGxlbWVudHMgYXRvbWljX3QgYXMgYSA2NC1iaXQgdmFsdWUg
YW5kIGV4cGVjdHMgYXRvbWljX3QNCnRvIGJlIDY0LWJpdCBhbGlnbmVkLCBidXQgZG9lcyBub3Ro
aW5nIHRvIGVuc3VyZSB0aGF0Lg0KDQpGb3IgeDg2LCBhdG9taWNfdCBpcyBhIDMyLWJpdCB2YWx1
ZSBhbmQgYXRvbWljNjRfdCBpcyBhIDY0LWJpdCB2YWx1ZSwgYW5kDQp0aGUgZGVmaW5pdGlvbiBv
ZiBhdG9taWM2NF90IGlzIG92ZXJyaWRkZW4gaW4gYSB3YXkgdGhhdCBlbnN1cmVzDQo2NC1iaXQg
KDggYnl0ZSkgYWxpZ25tZW50Og0KDQpHZW5lcmljIGRlZmluaXRpb25zIGFyZSBpbiBpbmNsdWRl
L2xpbnV4L3R5cGVzLmg6DQogICAgdHlwZWRlZiBzdHJ1Y3Qgew0KICAgICAgICAgICAgaW50IGNv
dW50ZXI7DQogICAgfSBhdG9taWNfdDsNCg0KICAgICNkZWZpbmUgQVRPTUlDX0lOSVQoaSkgeyAo
aSkgfQ0KDQogICAgI2lmZGVmIENPTkZJR182NEJJVA0KICAgIHR5cGVkZWYgc3RydWN0IHsNCiAg
ICAgICAgICAgIHM2NCBjb3VudGVyOw0KICAgIH0gYXRvbWljNjRfdDsNCiAgICAjZW5kaWYNCg0K
T3ZlcnJpZGUgaW4gYXJjaC94ODYvaW5jbHVkZS9hc20vYXRvbWljNjRfMzIuaDoNCiAgICB0eXBl
ZGVmIHN0cnVjdCB7DQogICAgICAgICAgICBzNjQgX19hbGlnbmVkKDgpIGNvdW50ZXI7DQogICAg
fSBhdG9taWM2NF90Ow0KDQpQZXJoYXBzIGlhNjQgbmVlZHMgdG8gdGFrZSBvdmVyIHRoZSBkZWZp
bml0aW9uIG9mIGJvdGggYXRvbWljX3QgYW5kIGF0b21pYzY0X3QNCmFuZCBkbyB0aGUgc2FtZT8N
Cg0K
