From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Thu, 26 Jul 2007 06:29:09 +0000
Subject: [PATCH 0/3] vector domain minor fixes
Message-Id: <1185431349.3917.64.camel@kane-linux>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

Here are some minor fix patches for vector domain:

    [PATCH 1/3] Add sanity check into __bind_irq_vector
    [PATCH 2/3] Fix wrong assumption in acpi_gsi_to_irq
    [PATCH 3/3] Fix wrong return value in parse_vector_domain

Thanks,
Kenji Kaneshige

