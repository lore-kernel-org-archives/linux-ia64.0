From: Jack Steiner <steiner@sgi.com>
Date: Wed, 03 Nov 2004 20:56:56 +0000
Subject: Externalize SLIT table
Message-Id: <20041103205655.GA5084@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


The SLIT table provides useful information on internode
distances. Has anyone considered externalizing this
table via /proc or some equivalent mechanism.

For example, something like the following would be useful:

	# cat /proc/acpi/slit
	010 066 046 066
	066 010 066 046
	046 066 010 020
	066 046 020 010


If this looks ok (or something equivalent), I'll generate a patch....

-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


