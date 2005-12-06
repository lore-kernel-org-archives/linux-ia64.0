From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 06 Dec 2005 15:15:20 +0000
Subject: RE: [PATCH] altix: pci_window fixup
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F05204ABE@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051129223714.2596.42757.40171@attica.americas.sgi.com>
In-Reply-To: <20051129223714.2596.42757.40171@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Here's a nitpicking comment.  The kernel janitors have been busy
cleaning up all the "kcalloc(1, ..." calls to make them use the
new "kzalloc()" call, and here you re-introduce a "kcalloc(1,":

- 	controller = kzalloc(sizeof(struct pci_controller), GFP_KERNEL);
+	/* Allocate a sn_pci_controller, which has a pci_controller struct
+	 * as the first member.
+	 */
+	sn_controller +	    kcalloc(1, sizeof(struct sn_pci_controller), GFP_KERNEL);

-Tony
