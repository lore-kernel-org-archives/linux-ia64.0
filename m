From: "Alexander A. Klimov" <grandmaster@al2klimov.de>
Date: Mon, 13 Jul 2020 21:55:06 +0000
Subject: [PATCH v2] ia64: Replace HTTP links with HTTPS ones
Message-Id: <20200713215506.44327-1-grandmaster@al2klimov.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200713083408.38154746@lwn.net>
In-Reply-To: <20200713083408.38154746@lwn.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com, fenghua.yu@intel.com, corbet@lwn.net, linux-ia64@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: "Alexander A. Klimov" <grandmaster@al2klimov.de>

Rationale:
Reduces attack surface on kernel devs opening the links for MITM
as HTTPS traffic is much harder to manipulate.

Deterministic algorithm:
For each file:
  If not .svg:
    For each line:
      If doesn't contain `\bxmlns\b`:
        For each link, `\bhttp://[^# \t\r\n]*(?:\w|/)`:
	  If neither `\bgnu\.org/license`, nor `\bmozilla\.org/MPL\b`:
            If both the HTTP and HTTPS versions
            return 200 OK and serve the same content:
              Replace HTTP with HTTPS.

Signed-off-by: Alexander A. Klimov <grandmaster@al2klimov.de>
---
 As you said I should not HTTPSify broken links...

 Documentation/ia64/xen.rst | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/Documentation/ia64/xen.rst b/Documentation/ia64/xen.rst
index 831339c74441..9da6abb02a2c 100644
--- a/Documentation/ia64/xen.rst
+++ b/Documentation/ia64/xen.rst
@@ -28,7 +28,7 @@ Getting and Building Xen and Dom0
 
 	# hg clone http://xenbits.xensource.com/ext/ia64/xen-unstable.hg
 	# cd xen-unstable.hg
-	# hg clone http://xenbits.xensource.com/ext/ia64/linux-2.6.18-xen.hg
+	# hg clone https://xenbits.xensource.com/ext/ia64/linux-2.6.18-xen.hg
 
  2. # make world
 
-- 
2.27.0
