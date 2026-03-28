# errgroup Pattern

## Overview

`golang.org/x/sync/errgroup` runs N goroutines concurrently and:
- Collects the **first error** (cancels others via context)
- Waits for all to finish
- Returns nil if all succeed

```go
import "golang.org/x/sync/errgroup"
```

## Basic Pattern

```go
func (s *PatientService) GetPatientWithAppointments(
    ctx context.Context,
    patientID string,
) (*PatientWithAppointments, error) {
    g, ctx := errgroup.WithContext(ctx)

    var patient *domain.Patient
    var appointments []*domain.Appointment

    g.Go(func() error {
        var err error
        patient, err = s.patientRepo.FindByID(ctx, patientID)
        return err
    })

    g.Go(func() error {
        var err error
        appointments, err = s.apptRepo.ListByPatient(ctx, patientID, time.Now().AddDate(0, -1, 0), time.Now())
        return err
    })

    if err := g.Wait(); err != nil {
        return nil, fmt.Errorf("get patient with appointments: %w", err)
    }

    return &PatientWithAppointments{
        Patient:      patient,
        Appointments: appointments,
    }, nil
}
```

## With Result Collection

When goroutines produce values, preallocate a slice to avoid races:

```go
func (s *DashboardService) GetDashboard(ctx context.Context, doctorID string) (*Dashboard, error) {
    type result struct {
        patients     []*patient.Patient
        appointments []*appointment.Appointment
        stats        *Stats
    }
    var res result

    g, ctx := errgroup.WithContext(ctx)

    g.Go(func() error {
        var err error
        res.patients, err = s.patientRepo.ListByDoctor(ctx, doctorID, 10)
        return err
    })

    g.Go(func() error {
        var err error
        res.appointments, err = s.apptRepo.ListTodayByDoctor(ctx, doctorID)
        return err
    })

    g.Go(func() error {
        var err error
        res.stats, err = s.statsRepo.GetDoctorStats(ctx, doctorID)
        return err
    })

    if err := g.Wait(); err != nil {
        return nil, fmt.Errorf("get dashboard: %w", err)
    }

    return &Dashboard{
        Patients:     res.patients,
        Appointments: res.appointments,
        Stats:        res.stats,
    }, nil
}
```

## With Concurrency Limit

`errgroup.SetLimit` bounds the number of goroutines:

```go
func (s *NotificationService) SendBulk(ctx context.Context, patientIDs []string, msg Message) error {
    g, ctx := errgroup.WithContext(ctx)
    g.SetLimit(20)  // max 20 concurrent goroutines

    for _, id := range patientIDs {
        id := id  // capture
        g.Go(func() error {
            return s.sendOne(ctx, id, msg)
        })
    }

    return g.Wait()
}
```

## errgroup vs sync.WaitGroup

| Use `errgroup` when:                    | Use `sync.WaitGroup` when:              |
|-----------------------------------------|-----------------------------------------|
| Any error should cancel remaining work  | All goroutines must complete regardless |
| First error is sufficient to fail fast  | You want to collect ALL errors          |
| You want built-in context propagation   | You need custom error collection logic  |
| Fixed set of independent tasks          | Dynamic task generation                 |

## Collecting All Errors (not just first)

If you need all errors, use WaitGroup + error channel:

```go
func processAll(ctx context.Context, items []Item) []error {
    var wg sync.WaitGroup
    errs := make(chan error, len(items))

    for _, item := range items {
        item := item
        wg.Add(1)
        go func() {
            defer wg.Done()
            if err := process(ctx, item); err != nil {
                errs <- fmt.Errorf("item %s: %w", item.ID, err)
            }
        }()
    }

    wg.Wait()
    close(errs)

    var allErrs []error
    for err := range errs { allErrs = append(allErrs, err) }
    return allErrs
}
```

## Startup Service Dependencies

Use errgroup for parallel startup of independent services:

```go
// bootstrap/setup.go
func startServices(ctx context.Context, app *App) error {
    g, ctx := errgroup.WithContext(ctx)

    g.Go(func() error {
        return app.kafkaConsumer.Start(ctx)
    })
    g.Go(func() error {
        return app.metricsServer.Start(ctx)
    })
    g.Go(func() error {
        return app.healthChecker.Start(ctx)
    })

    return g.Wait()
}
```
