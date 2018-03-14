From: Christoph Hellwig <hch@infradead.org>
Date: Wed, 14 Mar 2018 08:35:19 +0000
Subject: Re: [PATCH] PCI/MSI: Don't set up INTx if MSI or MSI-X is enabled
Message-Id: <20180314083519.GA24043@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <152097754955.241946.9551793957889760940.stgit@bhelgaas-glaptop.roam.corp.google.com>
In-Reply-To: <152097754955.241946.9551793957889760940.stgit@bhelgaas-glaptop.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <helgaas@kernel.org>
Cc: linux-pci@vger.kernel.org, Mikael Starvik <starvik@axis.com>, Jesper Nilsson <jesper.nilsson@axis.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, David Howells <dhowells@redhat.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, linux-cris-kernel@axis.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-am33-list@redhat.com

Should this logic go into a little helper so that everyone is kept
in sync?
