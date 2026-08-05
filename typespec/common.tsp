using TypeSpec.OpenAPI;
using TypeSpec.Http;

@format("uuid")
@extension("x-go-type", "uuid.UUID")
@extension(
    "x-go-type-import",
    #{
        path: "github.com/google/uuid",
    }
)
scalar uuid extends string;

@doc("A client-generated key containing 1-255 visible ASCII characters without whitespace.")
@minLength(1)
@maxLength(255)
@pattern("^[!-~]+$")
scalar IdempotencyKey extends string;

@doc("POSIX-compatible exit code: 0 for success and any number from 1 to 255 for anything else.")
scalar exitCode extends uint8;

@doc("E.g.: \"2020-01-17T00:44:37\".")
scalar timestamp extends string;

alias TaskDuration = DurationString | int64;

@extension("x-enum-varnames", #["Empty", "LowerThanOne"]) // Used to solve name clash in oapi-codegen.
enum DurationString {
    Empty: "";
    LowerThanOne: "< 1";
}

enum UnitStatus {
    USER_INPUT,
    FAILED,
    REJECTED,
    COMPLETE,
    PROCESSING,
}

enum TransferType {
    Standard: "standard",
    ZipFile: "zipfile",
    UnzippedBag: "unzipped bag",
    ZippedBag: "zipped bag",
    DSpace: "dspace",
    Maildir: "maildir",
    TRIM: "TRIM",
    Dataverse: "dataverse",
}

model ResultsResponse<T> is Response<200> {
    results: T[];
    message: string;
}

model OKResponse<Status = 200> is Response<Status> {
    error?: boolean = false;
    message: string;
}

@error
model Error {
    error: boolean = true;
    message: string;
}

@error
model ErrorResponse<Status> is Response<Status> {
    error: boolean = true;
    message: string;
}

@error
model NonSuccessErrorResponse<Status> is Response<Status> {
    success: boolean = false;
    error: string;
}

model Success {
    success: boolean = true;
}

alias SuccessResponse = Success | NonSuccessErrorResponse<404>;

model Removed is Response<200> {
    removed: boolean = true;
}

model NotRemoved {
    @statusCode _: 409 | 500;
    removed: boolean = false;
}
