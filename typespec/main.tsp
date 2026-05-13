import "@typespec/http";
import "@typespec/rest";
import "@typespec/openapi";
import "@typespec/openapi3";
import "@typespec/versioning";

import "./common.tsp";

using TypeSpec.OpenAPI;
using TypeSpec.Http;
using TypeSpec.Versioning;

@service(#{
    title: "Archivematica",
})
@route("/api")
@useAuth(ApiKeyAuth<ApiKeyLocation.header, "ApiKey">)
@versioned(Versions)
namespace Service {
    enum Versions {
        v1,
    }

    @route("/")
    namespace V1 {
        @tag("Transfer")
        @route("/transfer")
        namespace Transfer {
            @doc("Approve a transfer.")
            @route("/approve")
            @post
            op approve(
                @header
                contentType: "application/x-www-form-urlencoded",

                @doc("Directory the transfer is in currently.")
                directory: string,

                @doc("Type of the transfer.")
                type: TransferType,
            ): ApproveTransferResponse | ErrorResponse<500>;

            model ApproveTransferResponse is OKResponse {
                uuid: uuid;
            }

            @doc("List unapproved transfers.")
            @route("/unapproved")
            @get
            op listUnapproved(): ResultsResponse<Unapproved>;

            model Unapproved {
                type: TransferType;
                directory: string;
                uuid: uuid;
            }

            @doc("List completed transfers.")
            @route("/completed")
            @get
            op listCompleted(): ResultsResponse<uuid>;

            @doc("Read the status of a transfer.")
            @route("/status/{id}")
            @get
            op read(@path id: uuid): ReadResponse | ErrorResponse<400>;

            model ReadResponse is Response<200> {
                type: "transfer";
                directory: string;
                name: string;
                uuid: uuid;
                microservice: string;
                status: UnitStatus;
                sip_uuid?: uuid | "BACKLOG";
            }

            @doc("Start a new transfer.")
            @route("/start_transfer")
            @post
            op start(
                @header
                contentType: "application/x-www-form-urlencoded",

                @doc("Name of the transfer.")
                name: string,

                @doc("Type of the transfer.")
                type: TransferType,

                @doc("Accession number.")
                accession: string,

                @doc("Access system ID.")
                access_id: string,

                @doc("List of base64-encoded <location_uuid>:<relative_path> to be copied into the new transfer. Location UUIDs should be associated with this pipeline, and relative path should be relative to the location.")
                paths: string[],

                @doc("ID of the associated TransferMetadataSet for disk image ingest.")
                row_ids: string[],
            ): StartTransferResponse | ErrorResponse<500>;

            model StartTransferResponse is OKResponse<200> {
                path: string;
            }

            @doc("Approve re-ingest of an AIP to the beginning of transfer.")
            @route("/reingest")
            @post
            op reingest(
                @header
                contentType: "application/x-www-form-urlencoded",

                name: string,
                uuid: uuid,
            ): ReingestResponse | ErrorResponse<400 | 500>;

            model ReingestResponse is OKResponse {
                reingest_uuid: uuid;
            }

            @doc("Mark all completed transfers as hidden.")
            @route("/delete")
            @delete
            op deleteAll(): Removed | NotRemoved | Response<400>;

            @doc("Mark a transfer as hidden and hide in the dashboard.")
            @route("/{id}/delete")
            @post
            op delete(@path id: uuid): Removed | NotRemoved | Response<400>;
        }

        @tag("Ingest")
        @route("/ingest")
        namespace Ingest {
            @doc("List SIPs waiting for user input..")
            @route("/waiting")
            @get
            op listWaiting(): ResultsResponse<Waiting>;

            model Waiting {
                sip_directory: string;
                sip_uuid: uuid;
                sip_name: string;
                microservice: string;
            }

            @doc("List completed SIPs.")
            @route("/completed")
            @get
            op listCompleted(): ResultsResponse<uuid>;

            @doc("Read the status of a SIP.")
            @route("/status/{id}")
            @get
            op read(@path id: uuid): ReadResponse | ErrorResponse<400>;

            model ReadResponse is Response<200> {
                type: "SIP";
                directory: string;
                name: string;
                uuid: uuid;
                microservice: string;
                status: UnitStatus;
                sip_uuid?: uuid | "BACKLOG";
            }

            @doc("Mark all completed SIPs as hidden.")
            @route("/delete")
            @delete
            op deleteAll(): Removed | NotRemoved | Response<400>;

            @doc("Mark a SIP as hidden and hide in the dashboard.")
            @route("/{id}/delete")
            @post
            op delete(@path id: uuid): Removed | NotRemoved | Response<400>;

            @doc("Approve re-ingest of an AIP to the beginning of ingest.")
            @route("/reingest")
            @post
            op reingest(
                @header
                contentType: "application/x-www-form-urlencoded",

                name: string,
                uuid: uuid,
            ): ReingestResponse | ErrorResponse<400 | 500>;

            model ReingestResponse is OKResponse {
                reingest_uuid: uuid;
            }

            @doc("Approve an AIP partial re-ingest.")
            @route("/reingest/approve")
            @post
            op approveReingest(
                @header
                contentType: "application/x-www-form-urlencoded",

                uuid: uuid,
            ): OKResponse | ErrorResponse<400>;

            @doc("Add metadata files to a SIP.")
            @route("/copy_metadata_files")
            @post
            op copyMetadataFiles(
                @header
                contentType: "application/x-www-form-urlencoded",

                sip_uuid: uuid,
                paths: string[],
            ): OKResponse | ErrorResponse<400 | 500>;
        }

        @tag("Filesystem")
        @route("/filesystem")
        namespace Filesystem {
            @doc("List all levels of description configured.")
            @route("/administration/dips/atom/levels/")
            @get
            op listLevelsOfDescription(): LevelsOfDescriptionResponse;

            @doc("Read metadata for a path (currently only level of description).")
            @route("/metadata")
            @get
            op readMetadata(
                @query
                path: string,
            ): {
                @statusCode _: 200;
                level_of_description: string;
            } | {
                @statusCode _: 404;
            };

            @doc("Update metadata for a path (currently only level of descrption).")
            @route("/metadata")
            @post
            op updateMetadata(
                @header
                contentType: "application/x-www-form-urlencoded",

                path: string,
                level_of_description: string,
            ): {
                @statusCode _: 201;
                @body success: Success;
            } | {
                @statusCode _: 404;
            };
        }

        @tag("Administration")
        @route("/administration")
        namespace Administration {
            @doc("Fetches all levels of description from an AtoM datatabase, replacing any previously existing.")
            @route("/dips/atom/fetch_levels/")
            @get
            op fetchLevelsOfDescription(
            ): LevelsOfDescriptionResponse | NonSuccessErrorResponse<500>;
        }

        model LevelsOfDescriptionResponse is Response<200> {
            @body
            body: Record<uuid>[];
        }

        @tag("Processing Configuration")
        @route("/processing-configuration")
        namespace ProcessingConfiguration {
            @doc("Lists known processing configurations.")
            @get
            op list(): {
                @statusCode _: 200;

                @doc("List of config names.")
                @body
                body: string[];
            };

            @doc("Returns the processing configuration with the given name.")
            @route("/{name}")
            @get
            op read(
                @header accept: "*/*" | "application/xml" | "text/xml",
                @path name: string,
            ):
                | {
                      @statusCode _: 200;
                      ...ProcessingConfiguration;
                  }
                | {
                      @statusCode _: 415;
                  }
                | NonSuccessErrorResponse<404>
                | NonSuccessErrorResponse<500>;

            @doc("Deletes the processing configuration with the given name.")
            @route("/{name}")
            @delete
            op delete(@path name: string): SuccessResponse;

            model ProcessingConfiguration {
                @header contentType: "text/xml";
                @body body: string;
            }
        }
    }

    @route("/v2beta")
    namespace V2Beta {
        @tag("Packages")
        @route("/package")
        namespace Packages {
            @doc("Starts a new transfer.")
            @post
            op create(@body request: CreatePackageRequest): {
                @statusCode _: 201;
                @body response: CreatePackageResponse;
            } | ErrorResponse<400>;

            model CreatePackageRequest {
                name: string;
                path: string;
                access_system_id?: string;
                accession?: string;
                auto_approve?: boolean;
                processing_config?: string;
                type?: TransferType;
            }

            model CreatePackageResponse {
                id: uuid;
            }
        }

        @tag("Jobs")
        @route("/jobs")
        namespace Jobs {
            @doc("Return a list of jobs for the given package.")
            @route("/{id}")
            @get
            op list(
                @doc("Package ID")
                @path
                id: uuid,

                @doc("Name of the microservice the jobs belong to.")
                @query
                microservice?: string,

                @doc("UUID of the job chain link.")
                @query
                link_uuid: uuid,

                @doc("Name of the job.")
                @query
                name?: string,

                @doc("Include the task properties provided by the task endpoint.")
                @query
                detailed?: boolean,
            ): {
                @statusCode _: 200;
                @body response: ListJobsResponse;
            } | ErrorResponse<400>;

            alias ListJobsResponse = Job[];

            model Job {
                status: JobStatus;
                tasks: Task[];
                uuid: uuid;
                link_uuid: uuid;
                microservice: string;
                name: string;
            }

            enum JobStatus {
                Unknown: "UNKNOWN",
                AwaitingDecision: "USER_INPUT",
                CompletedSuccessfully: "COMPLETE",
                ExecutingCommands: "PROCESSING",
                StatusFailed: "FAILED",
            }

            // Slim view of a Task.
            model Task {
                uuid: uuid;
                exit_code: exitCode;
            }
        }

        @tag("Tasks")
        @route("/task")
        namespace Tasks {
            @doc("Return information about a task.")
            @route("/{id}")
            @get
            op read(@path id: uuid): {
                @statusCode _: 200;
                @body response: Task;
            } | ErrorResponse<400>;

            model Task {
                uuid: uuid;
                file_name: string;
                file_uuid: uuid;
                exit_code: exitCode;
                time_created: timestamp;
                time_started?: timestamp;
                time_ended?: timestamp;

                @doc("Task duration in seconds (integer). If the duration is less than a second, this will be a \"< 1\" string.")
                duration: TaskDuration;
            }
        }

        @tag("Validation")
        @route("/validate")
        namespace Validate {
            @doc("""
            Validate CSVs against embedded sets of rules.

            The status value may be one of:
            - `ok`: the submitted document is valid.
            - `bad request`: the submitted document is invalid.
            """)
            @route("/{validator}")
            @post
            op create(
                @header contentType: "text/csv; charset=utf-8",
                @path validator: Validator,
                @body _: bytes,
            ): {
                @statusCode _: 200;
                @body response: ValidDocumentResponse;
            } | {
                @statusCode _: 400;
                @body response: InvalidDocumentResponse | Error;
            } | ErrorResponse<404>;

            enum Validator {
                AvalonMediaSystemCSVManifest: "avalon",
                RightsCSV: "rights",
            }

            model ValidDocumentResponse {
                valid: boolean = true;
            }

            model InvalidDocumentResponse {
                valid: boolean = false;

                @minLength(1)
                reason: string;
            }
        }
    }
}
