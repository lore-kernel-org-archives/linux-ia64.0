From: Thomas Hiller <thomas.hiller@sap.com>
Date: Mon, 24 Jul 2000 15:36:26 +0000
Subject: [Linux-ia64] Internal compiler error in `reload_cse_simplify_operands'
Message-Id: <marc-linux-ia64-105590678205223@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

When compiling a c++ program I get:

alxxlog.c: In function `AlLogReadBlock':
alxxlog.c:750: Insn does not satisfy its constraints:
(insn 12571 12570 3243 (set (reg:DI 226 f98)
        (plus:DI (reg:DI 226 f98)
            (const_int -48 [0xffffffffffffffd0]))) 59 {adddi3} (nil)
    (expr_list:REG_EQUIV (plus:DI (reg:DI 328 fp)
            (const_int -48 [0xffffffffffffffd0]))
        (nil)))
alxxlog.c:750: Internal compiler error in
`reload_cse_simplify_operands', at reload1.c:8526

Kind regards,
Thomas

--
Thomas Hiller                                           thomas.hiller@compaq.com
COMPAQ Computer Corporation                             thomas.hiller@sap.com
Global SAP Solution Center                              Tel: +49 6227 / 7-45426
LinuxLab @ SAP, Walldorf                                Fax: +49 6227 / 7-43027





