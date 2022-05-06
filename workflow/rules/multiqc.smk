__author__ = "Patrik Smeds"
__copyright__ = "Copyright 2021, Patrik Smeds"
__email__ = "patrik.smeds@scilifelab.uu.se"
__license__ = "GPL-3"


rule multiqc:
    input:
        files=[
            file.format(sample=sample, type=u.type, lane=u.lane, flowcell=u.flowcell, barcode=u.barcode, read=read, ext=ext)
            for file in config["multiqc"]["qc_files"]
            for sample in get_samples(samples)
            for u in units.loc[sample].dropna().itertuples()
            for read in ["fastq1", "fastq2"]
            for ext in config.get("picard_collect_multiple_metrics", {}).get("output_ext", [""])
        ],
    output:
        temp("qc/multiqc/multiqc.html"),
        temp(directory("qc/multiqc/multiqc_data")),
    params:
        extra="{} {}".format(
            config.get("multiqc", {}).get("extra", ""),
            " -c {}".format(config["multiqc"]["config"]) if "config" in config.get("multiqc", {}) else "",
        ),
    log:
        "qc/multiqc/multiqc.html.log",
    benchmark:
        repeat("qc/multiqc/multiqc.html.benchmark.tsv", config.get("multiqc", {}).get("benchmark_repeats", 1))
    threads: config.get("multiqc", {}).get("threads", config["default_resources"]["threads"])
    resources:
        mem_mb=config.get("multiqc", {}).get("mem_mb", config["default_resources"]["mem_mb"]),
        mem_per_cpu=config.get("multiqc", {}).get("mem_per_cpu", config["default_resources"]["mem_per_cpu"]),
        partition=config.get("multiqc", {}).get("partition", config["default_resources"]["partition"]),
        threads=config.get("multiqc", {}).get("threads", config["default_resources"]["threads"]),
        time=config.get("multiqc", {}).get("time", config["default_resources"]["time"]),
    container:
        config.get("multiqc", {}).get("container", config["default_container"])
    conda:
        "../envs/multiqc.yaml"
    message:
        "{rule}: generate combined qc report at {output.html}"
    wrapper:
        "0.72.0/bio/multiqc"
