From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 13 Mar 2018 22:41:44 +0000
Subject: RE: [PATCH] PCI/MSI: Don't set up INTx if MSI or MSI-X is enabled
Message-Id: <3908561D78D1C84285E8C5FCA982C28F7B39A76B@ORSMSX110.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <152097754955.241946.9551793957889760940.stgit@bhelgaas-glaptop.roam.corp.google.com>
In-Reply-To: <152097754955.241946.9551793957889760940.stgit@bhelgaas-glaptop.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <helgaas@kernel.org>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>
Cc: Mikael Starvik <starvik@axis.com>, Jesper Nilsson <jesper.nilsson@axis.com>, "Yu, Fenghua" <fenghua.yu@intel.com>, David Howells <dhowells@redhat.com>, "Wysocki, Rafael J" <rafael.j.wysocki@intel.com>, "linux-cris-kernel@axis.com" <linux-cris-kernel@axis.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-am33-list@redhat.com" <linux-am33-list@redhat.com>

PiBDaGFuZ2UgdGhlIHJlbWFpbmluZyBhcmNoZXMgKGNyaXMsIGZydiwgYW5kIGlhNjQpIHRvIHNr
aXAgSU5UeCBzZXR1cCB3aGVuDQo+IGVpdGhlciBNU0kgb3IgTVNJLVggaXMgZW5hYmxlZC4NCg0K
TXkgaWE2NCBzdGlsbCBib290cyB3aXRoIHRoaXMgcGF0Y2ggYXBwbGllZCAoYW5kIGRvZXNuJ3Qg
aGF2ZSBhbnkgbmV3L2RpZmZlcmVudCBtZXNzYWdlcw0KaW4gdGhlIGNvbnNvbGUgbG9nKS4gIFNv
Og0KDQpUZXN0ZWQtYnk6IFRvbnkgTHVjayA8dG9ueS5sdWNrQGludGVsLmNvbT4NCg0KLVRvbnkN
Cg=
